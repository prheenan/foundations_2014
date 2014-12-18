function dydt = func_ODEs(t,y,conc,conc2,params)

kinetic_p=params;
dydt = zeros(numel(y),1);    % initialize dydyt as a column vector

%---------------------------------------------
% parameters
k1_reaction_0 = kinetic_p(1);
k2_reaction_0 = kinetic_p(2);
Kcat_reaction_1 = kinetic_p(3);
km_reaction_1 = kinetic_p(4);
k1_reaction_2 = kinetic_p(5);
Kcat_reaction_3 = kinetic_p(6);
km_reaction_3 = kinetic_p(7);
Kcat_reaction_4 = kinetic_p(8);
km_reaction_4 = kinetic_p(9);
Kcat_reaction_5 = kinetic_p(10);
km_reaction_5 = kinetic_p(11);
Kcat_reaction_6 = kinetic_p(12);
km_reaction_6 = kinetic_p(13);
Kcat_reaction_7 = kinetic_p(14);
km_reaction_7 = kinetic_p(15);
Kcat_reaction_8 = kinetic_p(16);
km_reaction_8 = kinetic_p(17);
Kcat_reaction_9 = kinetic_p(18);
km_reaction_9 = kinetic_p(19);
Kcat_reaction_10 = kinetic_p(20);
km_reaction_10 = kinetic_p(21);
Kcat_reaction_11 = kinetic_p(22);
km_reaction_11 = kinetic_p(23);
k1_reaction_12 = kinetic_p(24);
Kcat_reaction_13 = kinetic_p(25);
km_reaction_13 = kinetic_p(26);


k1_reaction_20 = kinetic_p(27);

v_reaction_28 = kinetic_p(28);
k1_reaction_29 = kinetic_p(29);

Kcat_reaction_14 = kinetic_p(30);
km_reaction_14 = kinetic_p(31);
Kcat_reaction_15 = kinetic_p(32);
km_reaction_15 = kinetic_p(33);
k1_reaction_16 = kinetic_p(34);
Kcat_reaction_17 = kinetic_p(35);
km_reaction_17 = kinetic_p(36);
k1_reaction_18 = kinetic_p(37);
Kcat_reaction_19 = kinetic_p(38);
km_reaction_19 = kinetic_p(39);


Kcat_ERKTACE = kinetic_p(40);
km_ERKTACE = kinetic_p(41);
k1_TACEdeg = kinetic_p(42);
k2_TACEsyn = kinetic_p(43);
Kcat_TACEpEGFl = kinetic_p(44);
km_TACEpEGFl = kinetic_p(45);

k1_pEGFldeg = kinetic_p(46);
k2_pEGFlsyn = kinetic_p(47);
k3_dif = kinetic_p(48);

kcat_41 = kinetic_p(49);
km_40 = kinetic_p(50);

kGM = kinetic_p(51);
kBMS = kinetic_p(52);
kGef = kinetic_p(53);
kZM = kinetic_p(54);
kCI = kinetic_p(55);
kSCH = kinetic_p(56);


%---------------------------------------------
%Species
aEGFR = y(1);
EGFR = y(2);
aSOS = y(3);
SOS = y(4);
aRAS = y(5);
RAS = y(6);
aRAF = y(7);
RAF = y(8);
aMEK = y(9);
MEK = y(10);
aERK = y(11);
ERK = y(12);
aRSK = y(13);
RSK = y(14);

aTACE=y(15);
TACE=y(16);
EGFl = y(17);
pEGFl = y(18);

aPI3K=y(19);
PI3K=y(20);
aAKT = y(21);
AKT = y(22);

PP2ase = y(23);
RAFppase = y(24);
RASGAP = y(25);

%--------------------------------------------------------
%Reactions
% aEGFR*EGFR*EGF - aEGFR
dydt(1) = ( + ((k1_reaction_0*EGFl*EGFR-k2_reaction_0*aEGFR)) - (k1_reaction_20*aEGFR) - (kGef*conc2(3)) );
dydt(2) = ( - ((k1_reaction_0*EGFl*EGFR-k2_reaction_0*aEGFR)) + (v_reaction_28) - (k1_reaction_29*EGFR));
% MM[aEGFR -> aSOS] - aSOS - [aRSK -> aSOS]
dydt(3) = ( + (Menten_Explicit_Enzyme(Kcat_reaction_1,aEGFR,SOS,km_reaction_1)) - (k1_reaction_2*aSOS) - (Menten_Explicit_Enzyme(Kcat_reaction_13,aRSK,aSOS,km_reaction_13)));
dydt(4) = ( - (Menten_Explicit_Enzyme(Kcat_reaction_1,aEGFR,SOS,km_reaction_1)) + (k1_reaction_2*aSOS) + (Menten_Explicit_Enzyme(Kcat_reaction_13,aRSK,aSOS,km_reaction_13)));
% [aSOS->Ras]-[GAPras->aRas]
dydt(5) = ( + (Menten_Explicit_Enzyme(Kcat_reaction_3,aSOS,RAS,km_reaction_3)) - (Menten_Explicit_Enzyme(Kcat_reaction_4,RASGAP,aRAS,km_reaction_4)));
dydt(6) = ( - (Menten_Explicit_Enzyme(Kcat_reaction_3,aSOS,RAS,km_reaction_3)) + (Menten_Explicit_Enzyme(Kcat_reaction_4,RASGAP,aRAS,km_reaction_4)));
% [aRas->Raf]-[Ppase->aRaf]-[aAKT->aRaf]
dydt(7) = ( + (Menten_Explicit_Enzyme(Kcat_reaction_5,aRAS,RAF,km_reaction_5)) - (Menten_Explicit_Enzyme(Kcat_reaction_6,RAFppase,aRAF,km_reaction_6)) - (Menten_Explicit_Enzyme(Kcat_reaction_19,aAKT,aRAF,km_reaction_19)) - (Menten_Explicit_Enzyme(kcat_41,aERK,aRAF,km_40)) - (kZM*conc2(4))); 
dydt(8) = ( - (Menten_Explicit_Enzyme(Kcat_reaction_5,aRAS,RAF,km_reaction_5)) + (Menten_Explicit_Enzyme(Kcat_reaction_6,RAFppase,aRAF,km_reaction_6)) + (Menten_Explicit_Enzyme(Kcat_reaction_19,aAKT,aRAF,km_reaction_19)) + (Menten_Explicit_Enzyme(kcat_41,aERK,aRAF,km_40))); 
% [aRaf->MEK]-[Ppase->aMEK]
dydt(9) = ( + (Menten_Explicit_Enzyme(Kcat_reaction_7,aRAF,MEK,km_reaction_7)) - (Menten_Explicit_Enzyme(Kcat_reaction_8,PP2ase,aMEK,km_reaction_8)) - (kCI*conc2(5)) );
dydt(10) = ( - (Menten_Explicit_Enzyme(Kcat_reaction_7,aRAF,MEK,km_reaction_7)) + (Menten_Explicit_Enzyme(Kcat_reaction_8,PP2ase,aMEK,km_reaction_8)));
% [aMEK-ERK]-[Ppase->aERK]
dydt(11) = ( + (Menten_Explicit_Enzyme(Kcat_reaction_9,aMEK,ERK,km_reaction_9)) - (Menten_Explicit_Enzyme(Kcat_reaction_10,PP2ase,aERK,km_reaction_10)) - (kSCH*conc2(6)) );
dydt(12) = ( - (Menten_Explicit_Enzyme(Kcat_reaction_9,aMEK,ERK,km_reaction_9)) + (Menten_Explicit_Enzyme(Kcat_reaction_10,PP2ase,aERK,km_reaction_10)) );
% [aERK->P90Rsk]-aP90Rsk
dydt(13) = ( + (Menten_Explicit_Enzyme(Kcat_reaction_11,aERK,RSK,km_reaction_11)) - (k1_reaction_12*aRSK));
dydt(14) = ( - (Menten_Explicit_Enzyme(Kcat_reaction_11,aERK,RSK,km_reaction_11)) + (k1_reaction_12*aRSK));
%ERK to TACE
dydt(15)= ( + (Menten_Explicit_Enzyme(Kcat_ERKTACE,aERK,TACE,km_ERKTACE)) - (k1_TACEdeg*aTACE) - (kGM*conc2(1)) - (kBMS*conc2(2)) );
dydt(16)= ( - (Menten_Explicit_Enzyme(Kcat_ERKTACE,aERK,TACE,km_ERKTACE)) + (k2_TACEsyn));
%Loss of EGFl
dydt(17)=( - ((k1_reaction_0*EGFl*EGFR-k2_reaction_0*aEGFR)) + Menten_Explicit_Enzyme(Kcat_TACEpEGFl,aTACE,pEGFl,km_TACEpEGFl) - (k3_dif*EGFl));
dydt(18)=( + (k2_pEGFlsyn) - (k1_pEGFldeg*pEGFl) - Menten_Explicit_Enzyme(Kcat_TACEpEGFl,aTACE,pEGFl,km_TACEpEGFl));
%PI3K and AKT
dydt(19) = ( + (Menten_Explicit_Enzyme(Kcat_reaction_14,aEGFR,PI3K,km_reaction_14)) + (Menten_Explicit_Enzyme(Kcat_reaction_15,aRAS,PI3K,km_reaction_15)) - (k1_reaction_16*aPI3K));
dydt(20) = ( - (Menten_Explicit_Enzyme(Kcat_reaction_14,aEGFR,PI3K,km_reaction_14)) - (Menten_Explicit_Enzyme(Kcat_reaction_15,aRAS,PI3K,km_reaction_15)) + (k1_reaction_16*aPI3K));
dydt(21) = ( + (Menten_Explicit_Enzyme(Kcat_reaction_17,aPI3K,AKT,km_reaction_17)) - (k1_reaction_18*aAKT));
dydt(22)  = ( - (Menten_Explicit_Enzyme(Kcat_reaction_17,aPI3K,AKT,km_reaction_17)) + (k1_reaction_18*aAKT));
%PPases and GAPS
dydt(23)=0;
dydt(24)=0;
dydt(25)=0;



%---------------------------------------------------
%Function definitions

%function Menten_Explicit_Enzyme

function returnValue = Menten_Explicit_Enzyme(Kcat, E, S, km)

returnValue = Kcat*E*S/(km+S);


