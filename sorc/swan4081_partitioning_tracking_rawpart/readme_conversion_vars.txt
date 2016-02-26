
Conversion of variables, Round 1:
------------------

flcomb
ihmax
wscut
ihmax
sig
wsmult
th
dera
dsip
ecos
esin
fachfe
dsii
fte
dth
tpiinv
hspmin
xfr
tpi
rade
iaproc
naperr
ndse

W3ODATMD, ONLY: IHMAX, HSPMIN, WSMULT

USE CONSTANTS

W3ODATMD, ONLY: WSCUT, FLCOMB

W3DISPMD, ONLY: WAVNU1

W3GDATMD, ONLY: DTH, SIG, DSII, DSIP, ECOS, ESIN, XFR, FACHFE, TH, FTE

W3ODATMD, ONLY: IAPROC, NAPERR, NDSE, NDST


Conversion of variables, Round 2:
------------------
               WW3:                                                             SWAN:
X  sig         R.A   Public   Relative frequencies (invariant in grid). (rad)   SPCSIG(MSC)     Relative frequencies in computational domain in sigma-space
v  th          R.A   Public   Directions (radians).                             SPCDIR(MDC,1)   Spectral directions (radians)
v  ecos        R.A   Public   Cosine of discrete directions.                    SPCDIR(ID,2)    = COS(SPCDIR(ID,1))
v  esin        R.A   Public   Sine of discrete directions.                      SPCDIR(ID,3)    = SIN(SPCDIR(ID,1))
v  dsip(NK)    R.A   Public   Frequency bandwidths (prop.) (rad)                
   fachfe      Real  Public   Factor for high-freq tail.                        PWTAIL(10)      Coefficients to calculate tail of the spectrum
v  dsii(NK)    R.A   Public   Frequency bandwidths (int.) (rad)                 FRINTF ??       Frequency integration factor (=df/f) 
   fte         Real  Public   Factor in tail integration energy 
                                   (= 0.25 * SIG(NK) * DTH * SIG(NK))
X  dth         Real  Public   Directional increments (radians).                 DDIR            Increment in directional space (in degrees???)
v  tpiinv      Real  Global   1/2pi.                                            N/A             1/PI2
v  tpi         Real  Global   2pi.                                              PI2 [CALCUL]    =2*PI;
v  rade        constant       = 180. / PI                                       DD              = 180./PI
v  dera        constant       = PI / 180.                                       DEGRAD          = PI/180.
X  xfr         Real  Public   Frequency multiplication factor.                  (1+FRINTF)      where FRINTF: Frequency integration factor (=df/f) (=ALOG(SHIG/SLOW)/(MSC-1))

W3GDATMD, ONLY: DTH, SIG, DSII, DSIP, ECOS, ESIN, XFR, FACHFE, TH, FTE


