%ReadC3DOptitrack
%-------------------------------------------------------------------------
%	LEES MIJ!
%   Deze bestanden mogen NIET in een ZIP-bestand staan.
%   Druk op F5 om het script te starten.
%	Dit script opent een C3D-bestand m.b.v. 'ReadC3DOptitrackFunction'
%	en plot de ingelezen gegevens.
%-------------------------------------------------------------------------
%
%
%	Dit script is geschreven voor Motive versie 1.8 of hoger.
%
%	   Copyright (C) 2013  M. Schrauwen (mjschrau@hhs.nl)
%
%	   This program is free software: you can redistribute it and/or modify
%	   it under the terms of the GNU General Public License as published by
%	   the Free Software Foundation, either version 3 of the License, or
%	   (at your option) any later version.
%
%	   This program is distributed in the hope that it will be useful,
%	   but WITHOUT ANY WARRANTY; without even the implied warranty of
%	   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%	   GNU General Public License for more details.
%
%	   You should have received a copy of the GNU General Public License
%	   along with this program.  If not, see <http://www.gnu.org/licenses/>.

%	LET OP! De namen van de assen (X, Y of Z) van het globale assenstelsel van het Optitrack
%	systeem varieert per applicatie & locatie. Om zoveel mogelijk gestandariseerd
%	te werk te gaan kan in dit script gebruik worden gemaakt van de 'ISB Global
%	coordinate systems' standaard.
%
%	Dit script maakt standaard gebruik van de Optitrack coordinaten zoals
%	aangegeven op de Ground base.
%
%
%	 		GROUNDBASE (MOTIVE >= versie 1.7):
%			                           (BOVENAANZICHT)
%	     _*_ _ _Z+_ _ _ _*_        (* = marker)
%	     |						   (hoogte is Y)
%		 |X-
%		 |
%		 *
%
%	Opmerking:
%	Het is belangrijk dat tijdens kalibratie goed in de gaten wordt gehouden
%	wat de richting is van de ground base van het Optitrack systeem.
%
%	In het kort houdt de 'ISB Global coordinate systems standaard' het
%	volgende in voor data van het Optitrack systeem in dit script.
%	X+ is in de richting van de lange zijde van grondmarker (de +Z van Opti.)
%	X- is in tegenstelde richting.
%	Y+ is de positieve verticaal in tegenstelde richting van de zwaartekracht.
%	Y- is in richting van de zwaartekracht.
%	Z+ is in de richting van de korte zijde van de grondmarker.
%	Z- is in tegenstelde richting.
%
%	DIRECTE VERTALING:
%	BT ISB coordinaten    | Optitrack systeem coordinaten
%	-----------------------------------------------------
%	          X+          |              Z-
%	          X-          |              Z+
%	          Y+          |              Y+
%	          Y-          |              Y-
%	          Z+          |              X+
%	          Z-          |              X-
%
%	Gebruikte documentatie: https://code.google.com/p/b-tk/
%	MS2013 (mjschrau@hhs.nl)


%%	$Revisie: 1.0.0.3 $  $Date: 2013-11-10 $
%	de juiste bestanden toevoegen (MS)
%%	$Revisie: 1.0.0.4 $  $Date: 2014-09-11 $
%	onderscheid gemaakt tussen ISB en OPTI coordinaten zie helemaal onderaan
%	dit bestand. (MS)
%%	$Revisie: 1.0.0.5 $  $Date: 2015-03-11 $
%	Standaard 3D plots in Optitrack coordinaten (MS)
%%	$Revisie: 1.0.0.6 $  $Date: 2015-03-12 $
%	De C3D coordinaten en Optitrack coordinaten worden niet één-op-één
%	overgenomen. Dit is nu aangepast op basis van een bekende meting. Met
%	dank aan de tweedejaars BT studenten die dit hebben opgemerkt! (MS)
%%	$Revisie: 1.0.1.0 $  $Date: 2015-03-19 $
%	De code van dit script is in een function file geplaatst zodat het
%	gemakkelijk door andere scripts kan worden aangeroepen. (MS)
%%	$Revisie: 1.0.1.1 $  $Date: 2015-03-20 $
%	De oorspronkelijk gedachte was dat de lange zijde van de groundbase positief
%	was en dat de korte zijde van de x positief was, was fout. Dit was erg onduidelijk
%	van Optitrack. Dit is nu op basis van enkele testen verbeterd.
%	Naslag: http://wiki.optitrack.com/index.php?title=Motive_Streaming. Dit
%	script werkt nu nog op basis van Motive 1.5. En gaat medio april 2015
%	over naar de laatste versie van Motive 1.7 waarbij de coordinaten wederom
%	veranderen. (MS)
%%	$Revisie: 1.0.1.2 $  $Date: 2015-03-21 $
%	Script geoptimaliseerd en code verduidelijkt. Tijd toegevoegd aan
%	grafieken (MS)
%%	$Revisie: 1.0.1.3 $  $Date: 2015-08-26 $
%	Nieuwe coordinatensysteem verwerkt (MS)
%%	$Revisie: 1.0.2.0 $  $Date: 2015-08-26 $
%	Dit script en de functionfile opnieuw aangepast zodat de function file
%	automatisch de juiste coordinaten doorgeeft volgens Optitrack format (zie
%	hierboven). (MS)
%%	$Revisie: 1.0.3.0 $  $Date: 2016-12-15 $
%	Zie aanpassingen in Read3DOptitrackFunction (MS)
%%	$Revisie: 1.0.4.0 $  $Date: 2017-2-21 $
%	Added functionality to read forces and moments recorded with a
%	forceplate (MS)

clc;
clear all;
close all;
cd(fileparts(mfilename('fullpath')));
addpath(genpath('../'));
[fileName pathName] = uigetfile('.c3d');
[coordinaten, namen, nChan, fs, nSamples, unit, ForcesAndMoments] = ReadC3DOptitrackFunction(pathName, fileName);

%%	opvragen van acties van gebruiker
disp(['Er zijn ' num2str(nChan) ' kanalen (markers) beschikbaar']);
disp('Druk 5 keer op ENTER als je alles wilt plotten');
beginKanaal      = input('Typ het begin kanaalnummer in: ');
eindKanaal       = input('Typ het eind kanaalnummer in :');
bl3Dplots        = input('Wilt u 3D-plots zien? (J=>1, N==0): ');
blPlots          = input('Wilt u normale-plots zien? (J=>1, N==0): ');
blAllInOne3DPlot = input('Wilt u alle data in 1 3D-plot zetten (J=>1, N==0): ');

%%	controleren of gebruiker input heeft gegeven.
if length(beginKanaal) == 0
    beginKanaal = 1;
end
if length(eindKanaal) == 0
    eindKanaal = nChan;
end
if length(bl3Dplots) == 0
    bl3Dplots = 1;
end
if length(blPlots) == 0
    blPlots = 1;
end
if length(blAllInOne3DPlot) == 0
    blAllInOne3DPlot = 1;
end

%%	plot x-y-z
t = (0:(1/fs):(nSamples/fs)-(1/fs))';
coordinatenISB = cell(1,nChan);

for kanaal = beginKanaal:eindKanaal
    x =  coordinaten{kanaal}(:,1)';
    y =  coordinaten{kanaal}(:,2)';
    z =  coordinaten{kanaal}(:,3)';
    
    %%	ISB coordinaten aanmaken
    %	    coordinatenISB{kanaal}(:,1) = z;
    %	    coordinatenISB{kanaal}(:,2) = y;
    %	    coordinatenISB{kanaal}(:,3) = -x;
    if blPlots
        figure('units','normalized','outerposition',[0 0 1 1]);
        subplot(3,1,1), plot(t,x,'r')
        title(['OPTI-X-Plot in ' unit]);
        grid 'minor'
        xlabel('Tijd [s]');
        ylabel('Positie');
        subplot(3,1,2), plot(t,y,'b')
        title(['OPTI-Y-Plot in ' unit]);
        grid 'minor'
        xlabel('Tijd [s]');
        ylabel('Positie');
        subplot(3,1,3), plot(t,z,'g')
        title(['OPTI-Z-Plot in ' unit]);
        grid 'minor'
        xlabel('Tijd [s]');
        ylabel('Positie');
    end
    if bl3Dplots
        %3D-plot eerste 2 datapunten
        figure('units','normalized','outerposition',[0 0 1 1]);
        col = (1:length(x));
        surface([x;x],[y;y],[z;z],[col;col],...
            'facecol','no',...
            'edgecol','interp',...
            'linew',2);
        title(['3DPlot (Optitrack coordinaten): ' namen(kanaal) 'in' unit]);
        view(3)
        grid 'minor'
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
    end
end

%%	alle markers (kanalen) in 3D plot
if blAllInOne3DPlot
    figure('units','normalized','outerposition',[0 0 1 1]);
    for kanaal = beginKanaal:eindKanaal
        %%	3D-plot eerste 2 datapunten
        col = (1:length(x));
        surface([x;x],[y;y],[z;z],[col;col],...
            'facecol','no',...
            'edgecol','interp',...
            'linew',2);
        title(['3DPlot (Optitrack coordinaten): ' namen(kanaal) 'in' unit]);
        view(3)
        hold on;
    end
    %	plot kubus op eerste startpunt
    size = 5;
    x = coordinaten{kanaal}(1,1);
    y = coordinaten{kanaal}(1,2);
    z = coordinaten{kanaal}(1,3);
    plotcube([size size size],[x y z],.8,[0 1 0]);
    grid 'minor'
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
end

%% teken krachten en momenten
if ~isempty(fieldnames(ForcesAndMoments))
    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(2,1,1), plot(ForcesAndMoments.Fx1,'r')
    hold on;
    grid 'minor'
    subplot(2,1,1), plot(ForcesAndMoments.Fy1,'g')
    subplot(2,1,1), plot(ForcesAndMoments.Fz1,'b')
    xlabel('Time (samples)');
    ylabel('Force');
    subplot(2,1,2), plot(ForcesAndMoments.Mx1,'r')
    hold on;
    grid 'minor'
    subplot(2,1,2), plot(ForcesAndMoments.My1,'g')
    subplot(2,1,2), plot(ForcesAndMoments.Mz1,'b')
    xlabel('Time (samples)');
    ylabel('Moments');
end

%%	VOORBEELD
%	%voorbeeld gebruik van alle ingelezen coordinaten
%	volgens OPTITRACK (NIET ISB)
%	coordinaten{1}(:,1) %eerste marker x-coordinaten
%	coordinaten{2}(:,2) %tweede marker y-coordinaten
%	coordinaten{5}(:,3) %vijfde marker z-coordinaten
%	coordinaten{9}(:,3) %negende marker z-coordinaten

%	%voorbeeld gebruik van alle ingelezen coordinaten
%	volgens ISB
%	coordinatenISB{1}(:,1) %eerste marker x-coordinaten
%	coordinatenISB{2}(:,2) %tweede marker y-coordinaten
%	coordinatenISB{5}(:,3) %vijfde marker z-coordinaten
%	coordinatenISB{9}(:,3) %negende marker z-coordinaten


