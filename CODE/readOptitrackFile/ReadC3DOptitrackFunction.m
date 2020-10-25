%	ReadC3DOptitrackFunction
%	Dit script leest een C3D bestand in op basis van een bestandsnaam en pathname.
%	
%	Copyright (C) 2014  M. Schrauwen (mjschrau@hhs.nl)
%	
%	This program is free software: you can redistribute it and/or modify
%	it under the terms of the GNU General Public License as published by
%	the Free Software Foundation, either version 3 of the License, or
%	(at your option) any later version.
%	
%	This program is distributed in the hope that it will be useful,
%	but WITHOUT ANY WARRANTY; without even the implied warranty of
%	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%	GNU General Public License for more details.
%	
%	You should have received a copy of the GNU General Public License
%	along with this program.  If not, see <http://www.gnu.org/licenses/>.
%	
%	Dit script maakt standaard gebruik van de Optitrack coordinaten zoals
%	aangegeven op de Ground base.
%	
%	
%			GROUNDBASE (MOTIVE >= versie 1.7):
%			                           (BOVENAANZICHT)
%			  _*_ _ _Z+_ _ _ _*_        (* = marker)
%			 |						   (hoogte is Y)
%			 |X-
%			 |
%			 *
%	
%	
%	Opmerking:
%	Het is belangrijk dat tijdens kalibratie goed in de gaten wordt gehouden
%	wat de richting is van de ground base van het Optitrack systeem.
%	
%	LET OP! Het filteren van missing data staat standaard uit! en kan worden aangezet
%	door blFillMissingData = 1; te maken.
%	
%	GEBRUIK:
%	[coordinaten, namen, aantalKanalen, sampleFrequentie, numberOfSamples, eenheid] = ReadC3DOptitrackFunction(pathName, fileName);
%	zie ook: ReadC3DOptitrack
%	
%	Opmerking:
%	Het is belangrijk dat tijdens kalibratie goed in de gaten wordt gehouden
%	wat de richting is van de ground base van het Optitrack systeem.
%%	Gebruikte documentatie: https://code.google.com/p/b-tk/
%	
%	Vragen, op- en/of aanmerkingen of aanbevelingen stuur ze naar: mjschrau@hhs.nl
%	MS2015

%%	$Revisie: 0.0.0.0 $  $Date: 2015-03-19 $
%	eerste versie op basis van ReadC3DOptitrack.m
%%	$Revisie: 1.0.2.0 $  $Date: 2015-08-26 $
%	Dit script en de functionfile opnieuw aangepast zodat de function file
%	automatisch de juiste coordinaten doorgeeft volgens Optitrack format (zie
%	hierboven).
%%	$Revisie: 1.0.3.0 $  $Date: 2015-11-05 $
%	n.a.v. opmerking van A. Lagerberg de rigidBodyNamen volledig opslaan in de vorm
%	Rigidbodynaam_Marker_x
%%	$Revisie: 1.0.4.0 $  $Date: 2016-12-15 $
%	n.a.v. opmerking van M. Soeters, opnieuw gekeken naar de orientatie van
%	assen op basis van de Optitrack balk.
%   Deze regel aangepast:
%    coordinatenOPTI{kanaal} = [-schaling*dataMarker(:,1) schaling*dataMarker(:,3) schaling*dataMarker(:,2)];
%   aangepast naar:
%    coordinatenOPTI{kanaal} = [-schaling*dataMarker(:,1) schaling*dataMarker(:,2) schaling*dataMarker(:,3)];
%%	$Revisie: 1.0.4.0 $  $Date: 2017-05-16 $
%   MS2017: added the MAC version of the BTK library. Tested it!

function [coordinaten, namenVanKanalen, aantalKanalen, sampleFrequentie, aantalSamples, eenheid, analogs] = ReadC3DOptitrackFunction(pathNameC3D, fileNameC3D)

try
    addpath(genpath('Optitrack toebehoren'));
    switch computer
        case 'PCWIN'
            addpath(genpath('btk-0.2.1_Win7_MatlabR2009b_64bit'));  %	toevoegen van benodigde (sub)folders
        case 'PCWIN64'
            addpath(genpath('btk-0.2.1_Win7_MatlabR2009b_64bit'));  %	toevoegen van benodigde (sub)folders
        case 'MACI64'
            addpath(genpath('btk-0.3.0_MacOS10.7_MatlabR2009b_64bit'));  %	toevoegen van benodigde (sub)folders
        otherwise
            error('Niet het juiste OS (waarschijnlijk Linux of MAC)')
    end
catch err
    disp('Zorg dat de de folder "Optitrack toebehoren" in dezelfde folder');
    disp('staat als dit script');
end

%%	Testen of de path name niet te lang is
if length(pwd) > 127
    error('Zet de Optitrack bestanden in folder met een kortere pathname!!!');
end

%%	bestand kiezen door gebruiker
c3dFile = [pathNameC3D fileNameC3D];

%	data inlezen en interpreteren
[h, ~, ~] = btkReadAcquisition(c3dFile);
dataUnformatted  = btkGetMarkers(h);
namen            = fieldnames(dataUnformatted);
aantalKanalen    = length(namen);
sampleFrequentie = btkGetPointFrequency(h);
numberOfSamples  = btkGetPointFrameNumber(h);
samplePeriod     = 1/sampleFrequentie;

%%	bepalen hoeveel rigid bodies er zijn gebruikt
for kanalen = 1:length(namen)
    rigidBodyNamen{kanalen} = namen{kanalen}(1,1:end); %	het woordje Marker_x weghalen
end
uniekeNamen = unique(cellfun(@(x)(mat2str(x)),rigidBodyNamen,'uniformoutput',false));
% disp(['Er zijn ' num2str(length(uniekeNamen)) ' rigidbodies gedetecteerd:']);
% disp(uniekeNamen)

%	sorteren van namen op alfabetische volgorde
namen = sort(namen);

%	geven van info aan gebruiker
disp(['Er zijn ' num2str(aantalKanalen) ' kanalen (markers) beschikbaar']);
eenheidOrigineel = btkGetPointsUnit(h,'marker');

%%	data naar cm's. De standaard eenheid kan varieren.
schaling         = 0;
switch eenheidOrigineel
    case 'mm'
        schaling = 1/10;
    case 'm'
        schaling = 100;
    otherwise %	cm's
        schaling = 1;
end
eenheid          = 'cm';

%%	controleren of gebruiker input heeft gegeven.
beginKanaal       = 1;
eindKanaal        = aantalKanalen;
blFillMissingData = 0;

%%	geheugen reserveren voor de 'data' matrix (+1 voor tijd-kolom)
data        = zeros(numberOfSamples,((eindKanaal-beginKanaal)*3)+1);
t           = (0:samplePeriod:(numberOfSamples/sampleFrequentie)-samplePeriod)';
data(:,1)   = t;
coordinaten = zeros;

%%	door data lopen
for kanaal = beginKanaal:eindKanaal
    %	inlezen van x-y-z posities van marker (bolletje)
    dataMarker = eval(['dataUnformatted.',namen{kanaal}]);
    %	omgaan met missende data
    if blFillMissingData
        dataFiltered = FilterMissingData(dataMarker,'interPolate');
        warning(['Percentage missing data: ' num2str(dataFiltered{4}) ' %	'])
        disp(['Aantal waarschuwingen: ' num2str(dataFiltered{3})])
        dataMarker = dataFiltered{1};
    end
    coordinatenOPTI{kanaal} = [schaling*dataMarker(:,1) schaling*dataMarker(:,2) schaling*dataMarker(:,3)];
end
coordinaten = coordinatenOPTI;
namenVanKanalen = namen;
aantalSamples = numberOfSamples;
%% get analog data
analogs = btkGetAnalogs(h);