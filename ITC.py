import os
import sys
import glob
import numpy as np
import time
from scipy.interpolate import interp1d

all_filters = ["U","G","R","I"]
mypath = os.path.dirname(os.path.realpath(__file__))
VERBOSE = False

lmin, lmax, dl = 3000, 10500, .01

def spline(xp, yp, xn):
    f = interp1d(xp, yp, kind="cubic", fill_value = np.nan)
    #print "Fit spline to {} points, now eval on {}".format(len(xp),len(xn))
    return f(xn)

def log_time(label,start):
    if VERBOSE:
        print "{} ({:.1f}s)".format(label, time.time()-start)
        sys.stdout.flush()

def load_template(args, wlmin=3500, wlmax=12500):
    try:
        template_type = args[0]
    except:
        template_type = args
    
    xint = np.arange(lmin, lmax, dl)
    ltmpl=xint/10.

    # make itmpl, template intensity
    if template_type == "blackbody":
        temp = float(args[1])
        hconst=6.62607004e-34 #;J*s
        kconst=1.3806488e-23 #;J/K
        splight=3e8 #;m/s
        itmpl=2*hconst*splight**2/(xint/1e10)**5*1/(np.exp(hconst*splight/((xint/1e10)*kconst*temp))-1)    
    elif template_type == "powerlaw":
        expn = float(args[1])
        itmpl=ltmpl**expn
    else:
        with open(mypath+"/templates/lt","r") as fp:
            all_templates = fp.readlines()
        all_templates = map(lambda x: x.strip(), all_templates)
        assert template_type in all_templates, (template_type, all_templates)
        fname = mypath+"/templates/{}".format(template_type)
        ltmpl, itmpl = np.loadtxt(fname, unpack=True)
    
    ## NOT IMPLEMENTED: REDSHIFTING THE TEMPLATE (line 545 in ITC.pro)

    ltmpl = 10.*ltmpl
    return ltmpl, itmpl

def load_filter(filter):
    assert filter in all_filters, (filter, all_filters)
    filter_fnames = [mypath+"/filters/gmos_{}{}.txt".format(x+1,y) for x,y in enumerate(all_filters)]
    fname = filter_fnames[all_filters.index(filter)]
    lfl, ifl = np.loadtxt(fname, unpack=True, skiprows=2, comments="#")
    lfl *= 10.
    return lfl, ifl
    
def apply_filtermag_to_template(ltmpl, itmpl, filter, mag):
    # Feige66
    m0dict = {"U": 15.6287, "G": 16.0930, "R": 15.1777, "I": 14.6694}
    # Load filter response
    lfl, ifl = load_filter(filter)
    # Apply filter range
    start = time.time()
    xint = np.arange(lmin, lmax, dl)
    log_time("filtermag: Starting spline", start)
    tmpl = spline(ltmpl, itmpl, xint)
    log_time("filtermag: Finished spline", start)
    pos = np.where(xint < np.min(ltmpl))[0]
    if len(pos) > 0: tmpl[pos] = itmpl[0]
    pos = np.where(xint > np.max(ltmpl))[0]
    if len(pos) > 0: tmpl[pos] = itmpl[-1]
    # Apply magnitude
    pos = np.where(np.logical_and(xint >= np.min(lfl), xint <= np.max(lfl)))[0]
    cfxint = xint[pos]
    cftmpl = tmpl[pos]
    transm = spline(lfl, ifl, cfxint)
    conv = cftmpl*transm
    relflux = np.sum(conv)*dl
    
    m0 = m0dict[filter]
    fac = 10**((m0-mag)/2.5)/relflux
    itmpl *= fac
    return itmpl

IQ_to_seeing = {20: 0.6, 70: 0.85, 85: 1.10, 100: 1.90}
def compute_seeing_loss(seeing, return_fltot=False):
    a = np.arange(400)/50.
    psfg = np.exp(-(a-4.)**2 / (seeing/(4*np.log(2))**2))
    fiber = 1.20
    fltot = np.sum(psfg)
    frac = np.sum(psfg[np.logical_and(a >= 4-fiber/2., a <= 4+fiber/2.)])/fltot
    if return_fltot:
        return frac, fltot
    else: return frac

CC_to_extinc = {50: 0.0, 70: 0.3, 80: 1.0, 100: 3.0}

def compute_airmass_loss(airmass, ltmpl):
    extl=np.array([310 ,320 ,340 ,360 ,380 ,400 ,450 ,500 ,550 ,600 ,650 ,700 ,800 ,900 ,1100,1200,1250])*10
    extv=np.array([1.37,0.82,0.51,0.37,0.30,0.25,0.17,0.13,0.12,0.11,0.11,0.10,0.07,0.05,0.02,0.017,0.015])
    #print np.min(ltmpl), np.max(ltmpl), 
    ext = spline(extl,extv,ltmpl)
    return 1./(10.**((-0.4*ext)*(1-airmass)))

def compute_reddening_loss(AV, ltmpl, RV=3.1):
    if AV == 0:
        return 1.0

    yy = 1/(ltmpl/1e4) - 1.82
    ax=1+0.17699*yy-0.50447*yy**2-0.02427*yy**3+0.72085*yy**4+0.01979*yy**5-0.7753*yy**6+0.32999*yy**7
    bx=1.41338*yy+2.28305*yy**2+1.07233*yy**3-5.38434*yy**4-0.62251*yy**5+5.3026*yy**6-2.09002*yy**7
    Albd = (ax+bx/RV) * AV
    return 10**(-0.4 * Albd)


def load_base_sky(sky_brightness, xint):
    assert sky_brightness in [20, 50, 80, 100]
    sky20=(-5.23206)+(0.00281598)*xint+(-4.47676e-07)*xint**2+(7.82084e-12)*xint**3+(3.74855e-15)*xint**4+(-2.29490e-19)*xint**5
    if sky_brightness == 20:
        return sky20
    elif sky_brightness == 50:
        sky50r=(7.10159)+(-0.00428956)*xint+(1.25479e-06)*xint**2+(-1.71528e-10)*xint**3+(1.07836e-14)*xint**4+(-2.50147e-19)*xint**5
        return sky20*sky50r
    elif sky_brightness == 80:
        sky80r=(18.2547)+(-0.0117544)*xint+(3.47604e-06)*xint**2+(-4.88248e-10)*xint**3+(3.17787e-14)*xint**4+(-7.69180e-19)*xint**5
        return sky20*sky80r
    elif sky_brightness == 100:
        sky100r=(61.4096)+(-0.0407968)*xint+(1.21107e-05)*xint**2+(-1.72026e-09)*xint**3+(1.13804e-13)*xint**4+(-2.81462e-18)*xint**5
        return sky20*sky100r

def run_itc(template, filter, mag, sky_background, image_quality, cloud_cover, airmass, exptime, 
            wlmin=3500, wlmax=12500, read_mode="slow", spectral_mode=2, AV = 0., full_output=False):
    assert os.path.exists(mypath+"/templates/")
    assert os.path.exists(mypath+"/filters/")

    assert filter in all_filters
    assert sky_background in [20,50,80,100]
    assert image_quality in IQ_to_seeing
    assert cloud_cover in CC_to_extinc

    start = time.time()
    
    if read_mode == "slow":
        rdnoise = 2.9
    elif read_mode == "fast":
        rdnoise = 4.2
    else:
        raise ValueError(read_mode)

    ## Create template in this filter
    ltmpl, itmpl = load_template(template)
    log_time("Loaded template ({} points)".format(len(ltmpl)), start)
    itmpl = apply_filtermag_to_template(ltmpl, itmpl, filter, mag)
    log_time("Applied filter", start)
    
    ## Apply seeing, cloud cover, airmass, and reddening to the template
    seeing = IQ_to_seeing[image_quality]
    seeing_frac, psftot = compute_seeing_loss(seeing, return_fltot=True)
    CCfrac = 10**(-0.4 * CC_to_extinc[cloud_cover])
    log_time("Applied seeing + cloud cover", start)
    
    ii = (ltmpl >= wlmin) & (ltmpl <= wlmax)
    ltmpl = ltmpl[ii]
    itmpl = itmpl[ii]
    log_time("Cut template to {}-{}".format(wlmin, wlmax), start)

    # These are wavelength dependent
    airmass_frac = compute_airmass_loss(airmass, ltmpl)
    log_time("Applied airmass", start)
    reddening_frac = compute_reddening_loss(AV, ltmpl)
    log_time("Applied reddening", start)
    
    itmpl = itmpl * seeing_frac * CCfrac * airmass_frac * reddening_frac
    

    if spectral_mode == 1:
        resel = 1.73
        apert = 22
        xint = np.arange(int((10482.4-4027.93)/0.0500765)) * 0.0500765 + 4027.93
        pos1 = np.where(xint <= 6100)[0]
        pos2 = np.where(xint > 6100)[0]
        courbe1=(126493.96)+(-101.65126)*xint[pos1]+(0.030072982)*xint[pos1]**2+(-3.8942578e-06)*xint[pos1]**3+(1.8914048e-10)*xint[pos1]**4+(-1.9923782e-16)*xint[pos1]**5
        courbe2=(333149.04)+(-207.23682)*xint[pos2]+(0.050434062)*xint[pos2]**2+(-6.0012731e-06)*xint[pos2]**3+(3.5256076e-10)*xint[pos2]**4+(-8.2793750e-15)*xint[pos2]**5
    elif spectral_mode == 2:
        resel = 2.88
        apert = 12
        xint = np.arange(int((10482.4-4027.93)/0.0507818)) * 0.0507818 + 4027.93
        pos1 = np.where(xint <= 6100)[0]
        pos2 = np.where(xint > 6100)[0]
        courbe1=(494897.69)+(-457.00698)*xint[pos1]+(0.16576089)*xint[pos1]**2+(-2.9553033e-05)*xint[pos1]**3+(2.5947507e-09)*xint[pos1]**4+(-8.9681463e-14)*xint[pos1]**5
        courbe2=(-82782.277)+(79.397676)*xint[pos2]+(-0.027753900)*xint[pos2]**2+(4.5599693e-06)*xint[pos2]**3+(-3.5331153e-10)*xint[pos2]**4+(1.0381124e-14)*xint[pos2]**5
    else:
        raise ValueError(spectral_mode)
    courbe = np.concatenate([courbe1, courbe2])
    log_time("Computed courbe", start)
    
    sky = load_base_sky(sky_background, xint)
    sky *= exptime
    if spectral_mode == 1: sky *= 1/107.
    if spectral_mode == 2: sky *= 1/63.
    Nst = sky
    log_time("Computed sky", start)
    
    # Final template
    tmpl = spline(ltmpl, itmpl, xint)
    signal = tmpl * courbe * exptime
    
    # Total noise
    noise = np.sqrt(Nst + rdnoise**2) * np.sqrt(apert)
    #nores = np.sqrt(Nst + rdnoise**2) * np.sqrt(apert) * np.sqrt(resel)
    
    # Check for saturation
    nlt = 46400. # non-linearity threshold
    peak = np.max((signal + Nst)/psftot)
    if peak > nlt:
        print "WARNING: Saturated by a factor of {:.2f}".format(peak/nlt)
    
    if spectral_mode == 1:
        SNR = signal/np.sqrt(signal + noise**2)
    elif spectral_mode == 2:
        # Is this right..?
        SNR = signal/np.sqrt(signal + noise**2 + Nst)
    
    if full_output:
        return xint, SNR, signal, noise, Nst
    return xint, SNR


if __name__=="__main__":
    assert os.path.exists(mypath+"/templates/")
    assert os.path.exists(mypath+"/filters/")
    
    import matplotlib.pyplot as plt
    
    template = ["blackbody", 4800]
    sky_background = 20
    image_quality = 20
    cloud_cover = 50
    airmass = 1.0
    exposure_time = 1200.
    read_mode = "slow"
    spectral_mode = 2
    AV = 0.

    wl, SNR = run_itc(template, "G", 14.0, sky_background, image_quality, cloud_cover, airmass, exposure_time, 
                      read_mode=read_mode, spectral_mode=spectral_mode, AV = AV)
    plt.plot(wl, SNR)
    data = np.loadtxt("ITC_GRACES_BLACKBODY_1200.00s.dat")
    plt.plot(data[:,0], data[:,1])
    plt.show()
