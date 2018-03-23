pro ITC,dirtp=dirtp,dirpl=dirpl,target=target,custarg=custarg,temp=temp,expn=expn,mag=mag,filter=filter,z=z,Av=Av,Rv=Rv,SB=SB,IQ=IQ,CC=CC,airmass=airmass,exptime=exptime,rdmode=rdmode,mode=mode,help=help
;== A beta version of the ITC for GRACES was created in 20150918 by ANC
; Version 1.0. Released 20150922 by ANC
; Version 1.1. Released 20160208 by ANC - now can apply reddening to the template
; Version 1.2. Released 20160421 by ANC - cuts the template spectrum between 350nm and 1250nm. 
;                                         the iterator for the loop creating the .dat file is now in format long (works for IDL<8).
; Version 1.3. Released 20160823 by ANC - gets rid of some of the output curves, to avoid confusion in the ITC results. 
; Version 1.4. Released 20161006 by KC  - fixes problems with M giant templates.

if keyword_set(help) then begin
  print,''
  print,''
  print,''
  print,''
  print,'*************'
  print,'                              Help for the GRACES ITC'
  print,''
  print,''
  print,'Thanks for using the ITC''s help option. The following is detailing how it can be used:'
  print,''
  print,''
  print,'THE MINIMUM YOU SHOULD KNOW:'
  print,'  First, you might like to note that none of the INPUTs is mandatory. So the command can be as simple as:'
  print,''
  print,'      IDL> ITC'
  print,''
  print,'  The script will request you the necessary values that are not provided as an input. However, note that if you want'
  print,'  to use a redshift (z), it will not ask you for one. In such case, you better enter it as an input (see below how).'
  print,''
  print,''
  print,'OPTIONAL INPUTS:'
  print,''
  print,' -Path-'
  print,''
  print,'  dirtp = Path where you have installed the ITC. It should point to where the folders ''filter/'' and ''templates/'' are.'
  print,''
  print,'  dirpl = Path where you want to save the final plot. It assumed to be the same as dirtp if it is not provided.'
  print,''
  print,''
  print,' -Target Information-'
  print,'  target = This is the spectral type you want use for the time estimation. It has to be written exactly as expected'
  print,'           by the script. A spectral type A0III need to be written ''a0iii'', and a quasar is ''qso''. Upper cases are'
  print,'           accepted as well. If you cannot guess the exact spelling, do not provide any targat input, and you will'
  print,'           be provided with a list of choices. If you want to use a CUSTOM SED, simply write ''custom'' in the target'
  print,'           field. In this case, you are expected to give the filename of your custom spectrum, either as an input'
  print,'           or once a prompt is requesting it. Note that qso-at-z requires the optional redshift input.'  
  print,''
  print,'  custarg = Filename of your custom spectrum. The file has to be in ASCII format. The script expects 2 columns, one'
  print,'            contaning the wavelength (in nm), and a second one with the flux (any unit).'
  print,''
  print,'  mag = Magnitude of the target.'
  print,''
  print,'  filter = Filter in which the magnitude is given (u, g, r or i).'
  print,''
  print,'  Av = Extinction in V mag.'
  print,''
  print,'  Rv = Av/E(B-V) (default is 3.1; Cardelli, Clayton & Mathis 1989, ApJ, 345, 245).'
  print,''
  print,'  z = Redshift (z).'
  print,''
  print,''
  print,' -Observing conditions-'
  print,'  SB = Sky brightness. It can be set to ''20'' (dark), ''50'' (gray), ''80'' (less gray) or ''100'' (bright).'
  print,''
  print,'  IQ = Image quality. It can be set to ''20'', ''70'', ''85'' or ''100''.'
  print,'       (see http://www.gemini.edu/sciops/telescopes-and-sites/observing-condition-constraints#ImageQuality for more'
  print,'       details)'
  print,''
  print,'  CC = Cloud cover. It can be set to ''50'' (photometric), ''70'' (0.3mag extinction), ''80'' (1mag extinction) or'
  print,'       ''100'' (>3mag extinction).'
  print,''
  print,'  airmass = Air mass. The values are kept between 1 and 3, but note that we rarely observe at higher air mass than'
  print,'            2 (unless it is requested).'
  print,''
  print,''
  print,' -Details of observations-'
  print,'  exptime = Exposure time in seconds.'
  print,''
  print,'  rdmode = Read mode. It can be ''Slow'' (2.9 e-/pix) or ''Normal'' (4.2 e-/pix). No other read mode is offered.'
  print,''
  print,'  mode = Spectral mode. It can be ''1'' fiber (R=67.5k) or ''2'' fiber (R=40k).'
  print,''
  print,''
  print,'  help = This is what you typed to get here...'
  print,''
  print,''
  print,' -Warning-'
  print,'  The current version of the ITC DOES NOT take into account the central wavelength. The selected central wavelength'
  print,'  fixes at which wavelength the guiding will be optimized. It therefore corresponds to the wavelength that at which'
  print,'  the spectrum is the least affected by atmospheric differential refraction. For now, it is fixed to 700nm.'
  print,''
  print,''
  print,' -Example:'
  print,''
  print,'IDL> ITC,dirtp=''.'',dirpl=''.'',target=''QSO'',mag=20,cc=50,iq=70,sb=80,mode=2,exptime=3600,filter=''r'',airmass=1.5,rdmode=''slow'',z=4'
  print,''
  print,''
  print,'Once the script is done, it produces an .eps plot (in the directory pointed by the mandatory input) with the S/N'
  print,'estimate. It also prints lines with useful information. Please, copy and paste then in your proposal before where'
  print,'include the .eps plot. Here is an exemple of the printed lines:'
  print,''
  print,'  The spectral type selected is QSO'
  print,'  The target''s magnitude is 20 in the filter R'
  print,'  The spectrum is redshifted with z=4'
  print,''
  print,'  The sky brightness is 80%'
  print,'  The image quality is 70%'
  print,'  The cloud cover is 50%'
  print,'  The spectral mode is 2 fiber'
  print,'  The air mass is 1.50000'
  print,''
  print,'  The total exposure time is 3600 sec'
  print,'  The chosen read mode is slow'
  print,''
  print,''
  print,'****************************'
  print,'Additional notes:'
  print,''
  print,'!!! WARNING !!! Recommended maximum exposure time is 2400 sec per spectrum. We therefore suggest you to split your total exposure'
  print,'                       time into 2 spectra of 1800 sec. But, if needed, it can be set to an exposure time as high as 7200sec.'
  print,''
  print,''
  print,'Also note that a .dat file is created with the numeric values of the plot. It can be found in the same directory as the plot (dirpl).'
  print,''
  print,'__---^^^^---__'
  print,''
  print,'If you have any question or request, please contact the GRACES team'
  print,' (http://www.gemini.edu/sciops/instruments/graces/?q=sciops/instruments/graces).'
  print,''
  print,'**---____---**'
  print,''
  print,''

  goto,fin
endif

if N_params() lt 1 then begin
  print,''
  print,''
  print,'CALLING SEQUENCE:'
  print,''
  print,'ITC[,dirtp=dirtp,dirpl=dirpl,target=target,custarg=custarg,mag=mag,filter=filter,z=z,SB=SB,IQ=IQ,CC=CC'
  print,'    ,airmass=airmass,exptime=exptime,rdmode=rdmode,mode=mode,help=help]'
  print,''
  print,'Use ITC,/help to view program description'
  print,''
  print,''
  print,''
endif


;Requests missing mandatory inputs that are not provided.
; Path to templates/ and filters/
found=0
if keyword_set(dirtp) then if file_test(dirtp+'/templates') and file_test(dirtp+'/filters') then found=1
if found eq 0 then begin
  if keyword_set(dirtp) ne 1 then begin
    print,'NOTE: It is assumed that the folders ''filters/'' and ''templates/'' are in the current directory.'
    print,''
    print,''
    print,''
    dirtp='./'
  endif
  att=1
  while file_test(dirtp+'/templates')+file_test(dirtp+'/filters') ne 2 and att lt 4 do begin
    rep=''
    print,'The folders ''templates/'' and ''filters/'' could not be found in the directory '+dirtp+'.'
    read,'  Please try another directory: ',rep
    print,''
    dirtp=rep
    att=att+1
    if att eq 4 then begin 
      print,'Too many unsucceddful attempts. Please start again. Sorry!'
      goto,fin
    endif
    print,''
  endwhile
endif

if keyword_set(dirpl) then begin
  if file_test(dirpl) ne 1 then begin
    rep=''
    print,'The folders '+dirpl+' could not be found.'
    while strcmp(rep,'1')+strcmp(rep,'2')+strcmp(rep,'3') eq 0 do begin
      print,'Do you want to'
      print,'(1) try another direcotry?'
      print,'(2) make that directory?'
      print,'(3) abandon?'
      read,'  Your answer is: ',rep
      case rep of
        '1': begin
          dirpl=''
          read,'  Please try another directory: ',dirpl
          if file_test(dirpl) ne 1 then begin
            rep='0'
            print,'The folders '''+dirpl+''' could not be found.'
          endif
        end
        '2': spawn,'mkdir '+dirpl
        '3': goto,fin
      endcase
    endwhile
    print,''
  endif
endif else dirpl=dirtp

; Spectral template
readcol,dirtp+'/templates/lt',format='(a)',lst,/silent
found=0
if keyword_set(target) then if max(strcmp(strlowcase(target)+'.nm.gz',lst)) ne 0 then found=1
if keyword_set(target) then if max(strcmp(strlowcase(target),'blackbody')) ne 0 then found=1
if keyword_set(target) then if max(strcmp(strlowcase(target),'powerlaw')) ne 0 then found=1
if keyword_set(target) then if max(strcmp(strlowcase(target),'custom')) ne 0 then found=1
if found eq 0 then begin
  print,'Please choose the target spectral type'
  print,''
  for i=0,n_elements(lst)-1 do begin
    if i eq 0 then print,'Stellar :'
    if i eq 37 then begin
      print,''
      print,'Non-Stellar :'
    endif
    print,'  ('+strcompress(string(i+1),/remove_all)+') '+strupcase(strmid(lst[i],0,strlen(lst[i])-6))
  endfor
  print,''
  print,'  ('+strcompress(string(n_elements(lst)+1),/remove_all)+') BlackBody'
  print,'  ('+strcompress(string(n_elements(lst)+2),/remove_all)+') PowerLaw'
  print,'  ('+strcompress(string(n_elements(lst)+3),/remove_all)+') Custom'
  print,''
  lp=''
  read,'  Enter the number corresponding to the spectral type here : ',lp
  lp=uint(lp)
  if lp le 0 or lp gt n_elements(lst)+3 then begin
    while lp le 0 or lp gt n_elements(lst)+3 do begin
      lp=''
      read,'  Enter the number corresponding to the spectral type here : ',lp
      lp=uint(lp)
    endwhile
  endif
  if lp ge n_elements(lst)+1 then begin
    if lp eq n_elements(lst)+1 then target='blackbody.nm.gz'
    if lp eq n_elements(lst)+2 then target='powerlaw.nm.gz'
    if lp eq n_elements(lst)+3 then target='custom.nm.gz'
  endif else target=lst[lp-1]
  print,''
endif else target=strlowcase(target)+'.nm.gz'
if max(strcmp(strlowcase(target),'blackbody.nm.gz')) then begin
  if keyword_set(temp) ne 1 then begin
    temp=''
    read,'  Enter the temperature (K) for the Black Body here : ',temp
    temp=float(temp)
  endif
  hconst=6.62607004e-34 ;J*s
  kconst=1.3806488e-23 ;J/K
  splight=3e8 ;m/s
endif
if max(strcmp(strlowcase(target),'powerlaw.nm.gz')) then begin
  if keyword_set(expn) ne 1 then begin
    expn=''
    read,'  Enter the exponent for the Power Law here : ',expn
    temp=float(expn)
  endif
endif
if max(strcmp(strlowcase(target),'custom.nm.gz')) then begin
  if keyword_set(custarg) ne 1 then begin
    custarg=''
    read,'  Enter the filename of your custom spectral template here : ',custarg
  endif
  print,''
  att=1
  while file_test(custarg) eq 0 and att lt 4 do begin
    rep=''
    print,'The file '''+custarg+''' could not be found.'
    read,'  Please try another filename: ',rep
    print,''
    custarg=rep
    att=att+1
    if att eq 4 then begin 
      print,'Too many unsucceddful attempts. Please start again. Sorry!'
      goto,fin
    endif
    print,''
  endwhile
endif

; Magnitude
if keyword_set(mag) ne 1 then begin
  mag=''
  read,'What magnitude is the target? : ',mag
  mag=float(mag)
  print,''
endif

; Filter
lst=strmid(findfile(dirtp+'/filters/*'),8+strlen(dirtp)+1)
lfilt=lst
found=0
if keyword_set(filter) then if max(strcmp(strupcase(filter)+'.txt',strmid(lst,6))) ne 0 then found=1
if found eq 0 then begin
  print,'Please choose a filter'
  for i=0,n_elements(lst)-1 do print,'('+strcompress(string(i+1),/remove_all)+') '+strupcase(strmid(lst[i],6,1))
  lp=''
  read,'  Enter the number corresponding to the filter here : ',lp
  lp=uint(lp)
  if lp le 0 or lp gt n_elements(lst) then begin
    while lp le 0 or lp gt n_elements(lst) do begin
      lp=''
      read,'  Enter the number corresponding to the filter here : ',lp
      lp=uint(lp)
    endwhile
  endif
  filter=lst[lp-1]
  print,''
endif else filter='gmos_'+strcompress(string(where(strcmp(strupcase(filter)+'.txt',strmid(lst,6)) eq 1)+1),/remove_all)+strupcase(filter)+'.txt'

; Sky background
found=0
if keyword_set(SB) then begin
  lst=[20,50,80,100]
  if max(strcmp(lst,strlowcase(SB))) eq 1 then found=1
endif
if found eq 0 then begin  
  print,'What sky brightness would you like to use?'
  print,'(1) 20%'
  print,'(2) 50%'
  print,'(3) 80%'
  print,'(4) Any'
  rep=''
  read,' : ',rep
  rep=uint(rep)
  if rep le 0 or rep gt 4 then begin
    while rep le 0 or rep gt 4 do begin
      rep=''
      read,'  Enter the number corresponding to the sky brightness : ',rep
      rep=uint(rep)
    endwhile
  endif
  case rep of
    1:SB=20
    2:SB=50
    3:SB=80
    4:SB=100
  endcase
  print,''
endif

; Image Quality
found=0
if keyword_set(IQ) then begin
  lst=[20,70,85,100]
  if max(strcmp(lst,strlowcase(IQ))) eq 1 then found=1
endif
if found eq 0 then begin  
  print,'What image quality would you like to use?'
  print,'(1) 20%'
  print,'(2) 70%'
  print,'(3) 85%'
  print,'(4) Any'
  rep=''
  read,' : ',rep
  rep=uint(rep)
  if rep le 0 or rep gt 4 then begin
    while rep le 0 or rep gt 4 do begin
      rep=''
      read,'  Enter the number corresponding to the image quality : ',rep
      rep=uint(rep)
    endwhile
  endif
  case rep of
    1:IQ=20
    2:IQ=70
    3:IQ=85
    4:IQ=100
  endcase
  print,''
endif

; Cloud cover
found=0
if keyword_set(CC) then begin
  lst=[50,70,80,100]
  if max(where(lst eq CC)) ne -1 then found=1
endif
if found eq 0 then begin  
  print,'What could cover would you like to use?'
  print,'(1) 50%'
  print,'(2) 70%'
  print,'(3) 80%'
  print,'(4) Any'
  rep=''
  read,' : ',rep
  rep=uint(rep)
  if rep le 0 or rep gt 4 then begin
    while rep le 0 or rep gt 4 do begin
      rep=''
      read,'  Enter the number corresponding to the sky brightness : ',rep
      rep=uint(rep)
    endwhile
  endif
  case rep of
    1:CC=50
    2:CC=70
    3:CC=80
    4:CC=100
  endcase
  print,''
endif

; Airmass
if keyword_set(airmass) ne 1 then begin
  airmass=''
  read,'At what airmass would you accept to go? : ',airmass
  airmass=float(airmass)
  print,''
  while airmass lt 1 or airmass gt 3 do begin
    if airmass lt 1 then print,'  Airmass has to be greater than 1' else print,'  The telescope can hardly go that low'
    airmass=''
    read,'At what airmass would you accept to go? : ',airmass
    airmass=float(airmass)
    print,''
  endwhile
endif

; Exposure time
if keyword_set(exptime) ne 1 then begin
  exptime=''
  read,'What is the total exposure time (in sec)? : ',exptime
  exptime=float(exptime)
  print,''
endif

; Read mode
found=0
if keyword_set(rdmode) then begin
  lst=['slow','normal']
  if max(strcmp(lst,strlowcase(rdmode))) eq 1 then found=1
endif
if found eq 0 then begin  
  print,'What read mode would you like to use?'
  print,'(1) Slow (2.9 e-)'
  print,'(2) Normal (4.2 e-)'
  rep=''
  read,' : ',rep
  rep=uint(rep)
  if rep le 0 or rep gt 2 then begin
    while rep le 0 or rep gt 2 do begin
      rep=''
      read,'  Enter the number corresponding to the read mode : ',rep
      rep=uint(rep)
    endwhile
  endif
  case rep of
    1:rdmode='slow'
    2:rdmode='normal'
  endcase
  print,''
endif
if strcmp(rdmode,'slow') then rdnoise=2.9 else rdnoise=4.2

; Spectral mode
found=0
if keyword_set(mode) then if mode eq 1 or mode eq 2 then found=1
if found eq 0 then begin  
  print,'What spectral mode would you like to use?'
  print,'(1) 1 fiber (target only; R=67.5k)'
  print,'(2) 2 fiber (target+sky;  R=40k)'
  mode=''
  read,' : ',mode
  mode=uint(mode)
  if mode le 0 or mode gt 2 then begin
    while mode le 0 or mode gt 2 do begin
      mode=''
      read,'  Enter the number corresponding to the spectral mode : ',mode
      mode=uint(mode)
    endwhile
  endif
  print,''
endif

print,''
print,''
print,''
print,'!!!***Please, copy paste the following in the ITC example section : ***!!!'
print,''
print,''
extinf=''
pron=''
if strcmp(target,'blackbody.nm.gz') then begin
  extinf=' with a temperature of '+strcompress(string(temp),/remove_all)+' K.'
  pron='a '
endif
if strcmp(target,'powerlaw.nm.gz') then begin
  extinf=' with the exponent '+strcompress(string(expn),/remove_all)
  pron='a '
endif
print,'The spectral type selected is '+pron+strupcase(strmid(target,0,strlen(target)-6))+extinf
print,'The target''s magnitude is '+strcompress(string(mag),/remove_all)+' in the filter '+strupcase(strmid(filter,6,1))
if keyword_set(Rv) then nRv=strcompress(string(Rv),/remove_all) else nRv='3.1'
if keyword_set(Av) then print,'An extinction of Av='+strcompress(string(Av),/remove_all)+'mag is applied using Rv='+nRv
if keyword_set(z) then print,'The spectrum is redshifted with z='+strcompress(string(z),/remove_all)
print,''
print,'The sky brightness is '+strcompress(string(SB),/remove_all)+'%'
print,'The image quality is '+strcompress(string(IQ),/remove_all)+'%'
print,'The cloud cover is '+strcompress(string(CC),/remove_all)+'%'
print,'The spectral mode is '+strcompress(string(mode),/remove_all)+' fiber'
print,'The air mass is '+strcompress(string(airmass),/remove_all)
print,''
print,'The total exposure time is '+strcompress(string(exptime),/remove_all)+' sec'
print,'The chosen read mode is '+rdmode
print,''
print,''
print,''
print,'****************************'
print,'Additional notes:'
print,''
addn=0
if exptime gt 2400 then begin
  nfr=fix(exptime/2400.)
  if exptime mod 2400. ne 0 then nfr=nfr+1
  print,''
  print,'!!! WARNING !!! Recommended maximum exposure time is 2400 sec per spectrum. We therefore suggest you to split your total'
  print,'                exposure time into '+strcompress(string(nfr),/remove_all)+' spectra of '+strcompress(string(exptime/nfr),/remove_all)+' sec. But, if needed, it can be set to an exposure time as high'
  print,'                as 7200sec.'
  print,''
  addn=1
endif

;Temporary wavelength vector for the template spectrum
b1=3000
b2=10500
dl=1/100.
xint=findgen((b2-b1)/dl)*dl+b1
ltmpl=xint/10.


;Reads the template spectrum
if strcmp(target,'blackbody.nm.gz')+strcmp(target,'powerlaw.nm.gz')+strcmp(target,'custom.nm.gz') then begin
  case target of
    'blackbody.nm.gz':itmpl=2*hconst*splight^2/(xint/1e10)^5*1/(exp(hconst*splight/((xint/1e10)*kconst*temp))-1)
    'powerlaw.nm.gz': itmpl=ltmpl^expn
    'custom.nm.gz': readcol,custarg,format='(f,f)',ltmpl,itmpl,/silent 
  endcase
endif else readcol,dirtp+'/templates/'+target,format='(f,f)',ltmpl,itmpl,/silent,/compress
ltmpl=ltmpl*10
if keyword_set(z) then begin
  lsh=(z+1)*ltmpl
  dlt=ltmpl[1]-ltmpl[0]
  ltmpl=findgen((max(lsh)-b1)/dlt)*dlt+b1
  tmp=spline(lsh,itmpl,ltmpl)
  pos=where(ltmpl lt min(lsh))
  if max(pos) ne -1 then tmp[pos]=0
  itmpl=tmp
endif
readcol,dirtp+'/filters/'+filter,format='(f,f)',lfl,ifl,/silent
lfl=lfl*10
tmpl=spline(ltmpl,itmpl,xint)
pos=where(xint lt min(ltmpl))
if max(pos) ne -1 then tmpl[pos]=itmpl[0]
pos=where(xint gt max(ltmpl))
if max(pos) ne -1 then tmpl[pos]=itmpl[n_elements(itmpl)-1]

;Apply the target's magnitude to the spectral template
pos=where(xint ge min(lfl) and xint le max(lfl))
cfxint=xint[pos]
cftmpl=tmpl[pos]
transm=spline(lfl,ifl,cfxint)
conv=cftmpl*transm
relflux=total(conv)*dl

;   calculated m0 from the specphot standard Feige 66 observed with GRACES in June 2015.
case filter of
  lfilt[0]: m0=15.6287
  lfilt[1]: m0=16.0930
  lfilt[2]: m0=15.1777
  lfilt[3]: m0=14.6694
endcase
fac=10^((m0-mag)/2.5)/relflux

itmpl=itmpl*fac ;<- template!

;Applies weather conditions to the template
; IQ
case IQ of
  20: seeing=0.6
  70: seeing=0.85
  85: seeing=1.1
  100: seeing=1.9
endcase
;  profile (approx)
a=findgen(400)/50.
psfg=exp(-(a-4.)^2/(seeing/(4*alog(2))^2))
fiber=1.2
;  total flux
fltot=total(psfg)
;  flux loss
frac=total(psfg[where(a ge 4-fiber/2. and a le 4+fiber/2.)])/fltot

itmpl=itmpl*frac

; CC
case CC of
  50: ext=0
  70: ext=.3
  80: ext=1.
  100: ext=3.
endcase
frac=10^(-.4*ext)

itmpl=itmpl*frac

;Extinction at Maunakea
extl=[310 ,320 ,340 ,360 ,380 ,400 ,450 ,500 ,550 ,600 ,650 ,700 ,800 ,900 ,1100,1200,1250]*10
extv=[1.37,0.82,0.51,0.37,0.30,0.25,0.17,0.13,0.12,0.11,0.11,0.10,0.07,0.05,0.02,0.017,0.015]
;ext=spline(extl,extv,xint)
ext=spline(extl,extv,ltmpl)

itmpl=itmpl/(10.^((-0.4*ext)*(1-airmass)))

;Cuts the template between 350nm and 1250nm, a more reasonable interval for GRACES
pos=max(where(ltmpl lt 3500))
if max(pos) ne -1 then begin
  ltmpl=ltmpl[pos:n_elements(ltmpl)-1]
  itmpl=itmpl[pos:n_elements(itmpl)-1]
endif
pos=min(where(ltmpl gt 12500))
if max(pos) ne -1 then begin
  ltmpl=ltmpl[0:pos]
  itmpl=itmpl[0:pos]
endif

;Reddening curve
if keyword_set(Av) then begin
  if Av ne 0 then begin
    ;redl=[1000.,1110.,1250.,1430.,1670.,2000.,2220.,2500.,2850.,3330.,3650.,4000.,4400.,5000.,5530.,6700.,9000.,10000.,20000.,100000.]
    ;redk=[4.20, 3.70 ,3.30 ,3.00 ,2.70 ,2.80 ,2.90 ,2.30 ,1.97 ,1.69 ,1.58 ,1.45 ,1.32 ,1.13 ,1.00 ,0.74 ,0.46 ,0.38  ,0.11  ,0.00]
    ;kdR=spline(redl,redk,xint)
    ;Albd=kdR*Av
    yy=1/(ltmpl/1d4)-1.82
    ax=1+0.17699*yy-0.50447*yy^2-0.02427*yy^3+0.72085*yy^4+0.01979*yy^5-0.7753*yy^6+0.32999*yy^7
    bx=1.41338*yy+2.28305*yy^2+1.07233*yy^3-5.38434*yy^4-0.62251*yy^5+5.3026*yy^6-2.09002*yy^7
    if keyword_set(Rv) ne 1 then Rv=3.1
    Albd=(ax+bx/Rv)*Av
    itmpl=itmpl*(10.^(-0.4*Albd))
  endif
endif

;Fit over the observed spectrum of Feige 66 (2015)
if mode eq 1 then begin
  ;Interpolated wavelength vector
  ;xint=dindgen((10027.4-4028.07)/0.0500765)*0.0500765+4028.07
  xint=dindgen((10482.4-4027.93)/0.0500765)*0.0500765+4027.93
  pos1=where(xint le 6100)
  pos2=where(xint gt 6100)
  courbe1=(126493.96)+(-101.65126)*xint[pos1]+(0.030072982)*xint[pos1]^2+(-3.8942578e-06)*xint[pos1]^3+(1.8914048e-10)*xint[pos1]^4+(-1.9923782e-16)*xint[pos1]^5
  courbe2=(333149.04)+(-207.23682)*xint[pos2]+(0.050434062)*xint[pos2]^2+(-6.0012731e-06)*xint[pos2]^3+(3.5256076e-10)*xint[pos2]^4+(-8.2793750e-15)*xint[pos2]^5
endif else begin
  xint=dindgen((10482.4-4027.93)/0.0507818)*0.0507818+4027.93
  pos1=where(xint le 6100)
  pos2=where(xint gt 6100)
  courbe1=(494897.69)+(-457.00698)*xint[pos1]+(0.16576089)*xint[pos1]^2+(-2.9553033e-05)*xint[pos1]^3+(2.5947507e-09)*xint[pos1]^4+(-8.9681463e-14)*xint[pos1]^5
  courbe2=(-82782.277)+(79.397676)*xint[pos2]+(-0.027753900)*xint[pos2]^2+(4.5599693e-06)*xint[pos2]^3+(-3.5331153e-10)*xint[pos2]^4+(1.0381124e-14)*xint[pos2]^5
endelse
courbe=[courbe1,courbe2]

;Interpolation of the template spectrum
tmp=spline(ltmpl,itmpl,xint)
tmpl=tmp

if mode eq 1 then begin
  resel=1.73; 1 fiber mode
  apert=22; 1 fiber mode
endif else begin
  resel=2.88; 1 fiber mode
  apert=12; 2 fiber mode
endelse

;Sky spectrum (e-/s) 
sky20=(-5.23206)+(0.00281598)*xint+(-4.47676e-07)*xint^2+(7.82084e-12)*xint^3+(3.74855e-15)*xint^4+(-2.29490e-19)*xint^5
sky50r=(7.10159)+(-0.00428956)*xint+(1.25479e-06)*xint^2+(-1.71528e-10)*xint^3+(1.07836e-14)*xint^4+(-2.50147e-19)*xint^5
sky80r=(18.2547)+(-0.0117544)*xint+(3.47604e-06)*xint^2+(-4.88248e-10)*xint^3+(3.17787e-14)*xint^4+(-7.69180e-19)*xint^5
sky100r=(61.4096)+(-0.0407968)*xint+(1.21107e-05)*xint^2+(-1.72026e-09)*xint^3+(1.13804e-13)*xint^4+(-2.81462e-18)*xint^5
if mode eq 1 then sky20=sky20/107 else sky20=sky20/63

case SB of
  20:sky=sky20
  50:sky=sky20*sky50r
  80:sky=sky20*sky80r
  100:sky=sky20*sky100r
endcase
Nst=sky*exptime

;Total noise
noise=sqrt(Nst+rdnoise^2)*sqrt(apert)
;Total noise per res. el.
nores=sqrt(Nst+rdnoise^2)*sqrt(apert)*sqrt(resel)

;Total signal
signal=tmpl*courbe*exptime

;Checks for saturation
nlt=46400. ; non-linearity threshold
peak=max((signal+Nst)/total(psfg))
if peak ge nlt then begin
  nfr=fix((peak/(nlt/2.)))
  if exptime/nfr ge 1 then begin
    if exptime/nfr le 2400 then begin
      print,'!!! WARNING !!! It is recommended to split your total exposure time into '+strcompress(string(nfr),/remove_all)+' spectra'
      print,'                of '+strcompress(string(exptime/nfr),/remove_all)+' sec to avoid saturation.'
    endif else begin
      nfr=fix(exptime/2400.)
      if exptime mod 2400. ne 0 then nfr=nfr+1
      print,'!!! WARNING !!! It is recommended to split your total exposure time into '+strcompress(string(nfr),/remove_all)+' spectra'
      print,'                of '+strcompress(string(exptime/nfr),/remove_all)+' sec to avoid saturation.'
    endelse
  endif else begin
    print,'!!! ERROR !!! This target will saturate if it is observed without a ND fiter.'
  endelse
  print,''
  print,''
  addn=1
endif

;Signal to noise ratio
if mode eq 1 then begin
  SN=signal/sqrt(signal+noise^2)
  ;SNres will no longer be used
  ;SNres=signal*resel/sqrt(signal*resel+nores^2)
endif else begin
  SN=signal/sqrt(signal+Nst+noise^2)
  ;SNres will no longer be used
  ;SNres=signal*resel/sqrt(signal*resel+Nst(resel)+nores^2)
endelse

if addn eq 0 then print,'  No additional note.'
print,''
print,''
print,''
print,''


;Plotting
xr=[4000,10400]
;SNres will no longer be used
;yr=[0,max(SNres)*1.13]
;plot,xint,SNres,linestyle=2,xrange=xr,/xst,yrange=yr,/yst,xtitle='wavelength (A)',ytitle='S/N'
;oplot,xint,SN
yr=[0,max(SN)*1.13]
plot,xint,SN,xrange=xr,/xst,yrange=yr,/yst,xtitle='wavelength (A)',ytitle='S/N'
;SN per pixel bin will no longer be used either
;oplot,xint,SN*sqrt(0.6923),linestyle=1

;SNres will no longer be used
;oplot,[8500,9000],0.97*max(SNres)*[1,1],linestyle=1
;oplot,[8500,9000],1.02*max(SNres)*[1,1]
;oplot,[8500,9000],1.07*max(SNres)*[1,1],linestyle=2
;xyouts,9050,0.968*max(SNres),'S/N per pixel bin'
;xyouts,9050,1.018*max(SNres),'S/N per pixel'
;xyouts,9050,1.068*max(SNres),'S/N per resolution bin'
oplot,[8500,9000],1.02*max(SN)*[1,1]
xyouts,9050,1.018*max(SN),'S/N per pixel'

set_plot,'ps'
loadct,13
;SNres will no longer be used
;device,filename=dirpl+'/ITC_GRACES_'+strupcase(strmid(target,0,strlen(target)-6))+'_'+strcompress(string(exptime),/remove_all)+'s.eps',/color,/encapsulated,xsize=7,ysize=4,/inches
;plot,xint,SNres,linestyle=2,xrange=xr,/xst,yrange=yr,/yst,xtitle='wavelength (A)',ytitle='S/N'
;oplot,xint,SN,color=255
;oplot,xint,SN*sqrt(0.6923),linestyle=1,color=155
device,filename=dirpl+'/ITC_GRACES_'+strupcase(strmid(target,0,strlen(target)-6))+'_'+strcompress(string(exptime),/remove_all)+'s.eps',/encapsulated,xsize=7,ysize=4,/inches
plot,xint,SN,xrange=xr,/xst,yrange=yr,/yst,xtitle='wavelength (A)',ytitle='S/N'

;SNres will no longer be used
;oplot,[8000,8500],0.95*max(SNres)*[1,1],linestyle=1,color=155
;oplot,[8000,8500],1.01*max(SNres)*[1,1],color=255
;oplot,[8000,8500],1.07*max(SNres)*[1,1],linestyle=2
;xyouts,8590,0.968*max(SNres),'S/N per pixel bin'
;xyouts,8590,1.008*max(SNres),'S/N per pixel'
;xyouts,8590,1.068*max(SNres),'S/N per '+strmid(strcompress(string(resel),/remove_all),0,4)+'pix'
oplot,[8000,8500],1.01*max(SN)*[1,1]
xyouts,8590,1.008*max(SN),'S/N per pixel'
;SNres will no longer be used
;xyouts,4500,1.068*max(SNres),strupcase(strmid(target,0,strlen(target)-6))
;xyouts,4500,1.008*max(SNres),strcompress(string(mode),/remove_all)+' fiber mode'
xyouts,4500,1.068*max(SN),strupcase(strmid(target,0,strlen(target)-6))
xyouts,4500,1.008*max(SN),strcompress(string(mode),/remove_all)+' fiber mode'
device,/close
set_plot,'x'

openw,un,dirpl+'/ITC_GRACES_'+strupcase(strmid(target,0,strlen(target)-6))+'_'+strcompress(string(exptime),/remove_all)+'s.dat',/get_lun
;SNres will no longer be used
;printf,un,format='(a)','# Wav.Lgth(A) | S/N per pixel | S/N per res. el.'
;for i=0L,n_elements(xint)-1 do printf,un,format='(f,f,f)',xint[i],SN[i],SNres[i]
printf,un,format='(a)','# Wav.Lgth(A) | S/N per pixel'
for i=0L,n_elements(xint)-1 do printf,un,format='(f,f,f)',xint[i],SN[i]
close,un
free_lun,un

fin:
end

