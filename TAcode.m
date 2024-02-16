%%%%%_____TAcode.m GUI version    
%%%%%_____2019-09-25 (last modified, CB) 2020-03-05 according to last modified file system
%%%%%_____Authors: Christopher Bilinski      
%%%%%_____Contact: cgbilinsk@gmail.com
%%%%%_____Note: 2024-02-16: The most current version of the TA code for operating on the custom-made forms with 100 questions and 2 KEY ID's, image examform.svg / pdf / png 

%%%%%%%%%% edit 2019-09-25 %%%%%%%%%%
%%%%% changed code to block out names for FERPA standards

%%%%%%%%%% edit 2019-05-18 %%%%%%%%%%
%%%%% changed code to work for new template scantron form

%%%%%%%%%% edit 2018-03-20 %%%%%%%%%%
%%%%% added code to show files with errors in their ID numbers at end of grading

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%TO DO%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% make code be able to grade participation writings


function varargout = TAcode(varargin)
% TACODE MATLAB code for TAcode.fig
%      TACODE, by itself, creates a new TACODE or raises the existing
%      singleton*.
%
%      H = TACODE returns the handle to a new TACODE or the handle to
%      the existing singleton*.
%
%      TACODE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TACODE.M with the given input arguments.
%
%      TACODE('Property','Value',...) creates a new TACODE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TAcode_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TAcode_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TAcode

% Last Modified by GUIDE v2.5 27-Feb-2020 21:27:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TAcode_OpeningFcn, ...
                   'gui_OutputFcn',  @TAcode_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before TAcode is made visible.
function TAcode_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TAcode (see VARARGIN)

% Choose default command line output for TAcode
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TAcode wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TAcode_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

global answerkey
global numoptions
global studentRosterVal
global initialWD
global fileWD
global promptans_numanskeys

numoptions = 5;
initialWD = pwd;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%CONVERT PDF TO JPG%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global fileWD
global initialWD

%code to check if the Answer Keys directory exists two directories back, and if so cd to it for convenience
if(exist('../Quizzes') == 7)
	cd('../Quizzes');
end

[fileName,fileWD,fileind] = uigetfile('*.pdf','MultiSelect','on')
cd(fileWD);

%make jpgs folder
if(exist('Originaljpgs') ~= 7)
	mkdir('Originaljpgs')
end

%check if jpgs named "Batch*.jpg" already exist and if they do, ask the user if he wants to regenerate the jpgs or skip this step
existingjpgs = dir('Originaljpgs/Batch*.jpg');
if(isempty(existingjpgs) == 0)
	'*.jpg files already exists in this directory.  Please answer the popup dialogue to proceed.'
	promptans_skippdftojpg = inputdlg(['Do you want to ' sprintf('\n') '1) Recreate the jpgs (Warning, this may overwrite existing batches, so be sure to choose all of the files that you want analyzed) ' sprintf('\n') '2) Skip this step and use this directory with existing jpgs'],'Secret Smart Bee',1,{'1'});
end

if((isempty(existingjpgs) == 1) | (str2num(cell2mat(promptans_skippdftojpg)) == 1))

	%if the computer is a PC or Mac, find the location of the ghostscript launcher,
	%otherwise state that the operating system is not recognized and do nothing
	if(ispc)
		'You are on a PC, finding ghostscript...'
		[Result, GSPath] = system('WHERE /F /R "c:\Program Files" gswin64.exe');
	elseif(isunix)
		'You are on a Mac/Unix, assuming ghostscript is in /usr/local/bin/gs'
		GSPath = '/usr/local/bin/gs';
		%%%%%might need code to find ghostscript on a Mac here
	else
		error('Don''t recognize the operating system')
	end
	%remove newlines from file path
	GSPath = strrep(GSPath,char(10),'');

	for i=1:size(fileName,2)
		[GSPath,' -dSAFER -dBATCH -dNOPAUSE -sDEVICE=jpeg -r500 -sOutputFile=Originaljpgs/Batch',num2str(i),'_%03d.jpg ',fileName{i}];
		GSsystemstring(i,:) = [GSPath,' -dSAFER -dBATCH -dNOPAUSE -sDEVICE=jpeg -r500 -sOutputFile=Originaljpgs/Batch',num2str(i),'_%03d.jpg ',fileName{i}];
		system(GSsystemstring(i,:));
	end
	set(handles.pushbutton5,'string','Created JPGs','BackgroundColor','green');
else
	set(handles.pushbutton5,'string','Skipped creating JPGs','BackgroundColor','green');
end

%go back to initial directory at end of push button so that the next push button can be called
cd(initialWD);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%SELECT ANSWER KEY%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global answerkey
global initialWD
global fileWD
global promptans_numanskeys

%go to working directory to begin
cd(fileWD);

%code to check if the Answer Keys directory exists two directories back, and if so cd to it for convenience
if(exist('../../AnswerKeys') == 7)
	cd('../../AnswerKeys');
end

%%%choose how many answer keys you want
promptans_numanskeys = inputdlg(['How many answer keys do you want to use?'],'Secret Smart Bee',1,{'1'});
promptans_numanskeys

for i=1:str2num(cell2mat(promptans_numanskeys))
	%choose each answer key individually depending on how many you chose
	i
	[answerkeyname,answerkeypath]=uigetfile('*.txt');
	answerkeyfullpathname = [answerkeypath,answerkeyname];
	
	%open selected answer key and read in answers
	filedata_anskey = textread(answerkeyfullpathname,'','delimiter',' ','headerlines',1,'emptyvalue',nan)
	answerkey(i).question = filedata_anskey(:,1)';
	answerkey(i).answer = filedata_anskey(:,2)';
	
	if(size(filedata_anskey,2) == 3)
		answerkey(i).cor = filedata_anskey(:,3)';
	end
end

%go back to the usual working directory
cd(fileWD);

if(isempty(answerkey))
	set(handles.pushbutton2,'string','Failed to obtain answer key','BackgroundColor','red');
else
	set(handles.pushbutton2,'string','Obtained answer key','BackgroundColor','green');
end

%go back to initial directory at end of push button so that the next push button can be called
cd(initialWD);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%NEW ANSWER KEY%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in pushbutton4.
%New Answer Key
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global answerkey
global initialWD
global fileWD
global promptans_numanskeys

%go to working directory to begin
cd(fileWD);

%create a new answer key based on user input and store it
numquestions = str2num(input('How many questions? (1-50)\n', 's'));
for i=1:numquestions	
	i
	answerprompt(i,:) = {['Answer to question ',num2str(i),'? (1-5 :: A-E)\n']};
	answerkey(i) = input(char(answerprompt(i,:)))
end
yearseason = input('What year and season? Don''t put any spaces between the year and season, and spell the season out entirely (summer, fall, winter, spring) [2017spring]\n', 's');
quiznumber = input('Which quiz? (1-5)\n', 's');

%code to check if the Answer Keys directory exists two directories back, and if so cd to it for convenience
if(exist('../../AnswerKeys') == 7)
	cd('../../AnswerKeys');
	
	%save the answer key in the answer keys directory and then go back to the working directory
	%allow the answerkeyname to print to terminal so user can see what name it was created as in case of errors
	answerkeyname = ['anskey_',yearseason,'_quiz',quiznumber,'.txt']
	fileID = fopen(answerkeyname,'w');
	fprintf(fileID,'%8s %6s\n','Question','Answer');
	fprintf(fileID,'%1i %1i\n',[1:numquestions;answerkey]);
	fclose(fileID);
	cd(fileWD);
end

if(isempty(answerkey))
	set(handles.pushbutton4,'string','Failed to create new answer key','BackgroundColor','red');
else
	set(handles.pushbutton4,'string','Created new answer key','BackgroundColor','green');
end

%go back to initial directory at end of push button so that the next push button can be called
cd(initialWD);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%SELECT STUDENT ROSTER%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global studentRosterVal
global initialWD
global fileWD

%go to working directory to begin
cd(fileWD);

%code to check if the Student Rosters directory exists two directories back, and if so cd to it for convenience
if(exist('../../StudentRosters') == 7)
	cd('../../StudentRosters');
end

%read in student names and IDs
[studentrostername,studentrosterpath]=uigetfile('*.txt');
studentRosterFullPathName = [studentrosterpath,studentrostername];
fileID = fopen(studentRosterFullPathName,'r' );
studentRosterVal = textscan(fileID,'%s%s%d','Delimiter',',');
fclose(fileID);

%go back to the working directory
cd(fileWD);

%change the color and text of the push button to reflect the results
if(isempty(studentRosterVal))
	set(handles.pushbutton6,'string','Failed to obtain student roster','BackgroundColor','red');
else
	set(handles.pushbutton6,'string','Obtained student roster','BackgroundColor','green');
end

%go back to initial directory at end of push button so that the next push button can be called
cd(initialWD);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%GRADE QUIZES%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pushbutton1,'string','<html>Running <br>Cntrl+C in MATLAB to cancel','enable','off','BackgroundColor','red');

global answerkey
global numoptions
global studentRosterVal
global initialWD
global fileWD
global justparticipation
global promptans_numanskeys
tic

% Turn off this warning "Warning: Image is too big to fit on screen; displaying at ___% "
warning('off', 'Images:initSize:adjustingMag');

%handle optional variables

%go to working directory to begin
cd(fileWD);

%make processed folder
if(exist('Processed') ~= 7)
	mkdir('Processed')
end

if(ispc)
	'You are on a PC, using the ls command to find the filenames'
	filenames = ls('Originaljpgs/*.jpg');
elseif(isunix)
	'You are on a Mac/Unix, using the dir command to find the filenames'
	filenamesdir = dir('Originaljpgs/*.jpg');
	for i=1:size(filenamesdir)
		filenames(i,:) = filenamesdir(i).name;
	end
else
	error('Don''t recognize the operating system')
end

%for testing, use numfiles = 3 to run through this process quickly
%numfiles = 3;
numfiles = size(filenames,1);
if(isempty(answerkey))
	'No answer key present'
else
	for iii=1:numfiles
	%the for loop below is a placeholder for test cases
	%for iii=46
		iii
		clearvars scannedimageRGB scannedimagegray startbarcol endbarcol startbarcoltemp middlebarcol xpixels ypixels slantfit perpfit dim1initial dim2initial distanceteal dim1teal dim2teal totaldim1moveteal totaldim2moveteal perpmoveteal slantmoveteal distanceperpmoveteal distanceslantmoveteal perpscale slantscale horizontaloffset verticaloffset horizontalIDoffset verticalIDoffset distanceperpmovename distanceslantmovename perpmovename slantmovename nameloc distanceperp distanceslant perpmove slantmove ansloc IDdistanceperp IDdistanceslant IDperpmove IDslantmove IDloc anscolors IDcolors studentID studentIDstr plotting
		
		%warnings initialized
		warningdim2 = 0;
		
		%%%%%Make sure to fill in template values if using a different template for the scantron;
		%tvu = template value used (to mark locations in the code that need to be updated if the template changes
		templatedistanceperpmovediagonal = 2.2012e+03;
		templatedistanceslantmovediagonal = 2.1393e+03;
		templatedistanceperp = 229.3243;
		templatedistanceslant = 274.8693;
		template31distanceperp = 983.3242;
		template31distanceslant = 274.4394;
		template61distanceperp = 1.7323e+03;
		template61distanceslant = 274.0123;
		template91distanceperp = 2.4802e+03;
		template91distanceslant = 1.8606e+03;
		templatedistanceperpmovekey = 476.2542;
		templatedistanceslantmovekey = 151.7285;
		templateIDdistanceperp = 2.3926e+03;
		templateIDdistanceslant = 783.6359;
		templatedistanceperpmovename = 2.929222985878533e+03;
		templatedistanceslantmovename = 96.329854182194467;
		
		templateABoffset = 0.028941176470588;
		template12offset = 0.024000000000000;
		templateID00offset = 0.028470588235294;
		templateID01offset = 0.018363636363636;

		%read all file names and iterate over all of them
		scannedimageRGB = imread(['Originaljpgs/',filenames(iii,:)]);

		%template file when calibrating things
		%scannedimageRGB = imread('001.jpg');
		
		%create a grayscale version of the image
		scannedimagegray = rgb2gray(scannedimageRGB);

		%find the start and end of the black bar in each row
		for i=1:size(scannedimagegray,1)
			%maybe use this to make an improvement
			%&(scannedimageRGB(i,1:700,1)-scannedimagegray(i,1:700,2) < 5
			%make sure to ignore rows with no black markers, otherwise find the start and end pixels of the black marker for that row
			if(isempty(find(scannedimagegray(i,1:700) < 125, 1, 'first')))
				startbarcol(i) = NaN;
				endbarcol(i) = NaN;
			else
				startbarcoltemp(i) = find(scannedimagegray(i,1:700) < 125, 1, 'first');
				
				%scrub any black pixels that don't have a white pixel before them within 10 pixels
				while(not(any(scannedimagegray(i,startbarcoltemp(i)-10:startbarcoltemp(i)-1) > 240)))
					if(isempty(find(scannedimagegray(i,startbarcoltemp(i)+1:700) < 125, 1, 'first')))
						startbarcoltemp(i) = NaN;
						break
					else
						startbarcoltemp(i) = startbarcoltemp(i)+ find(scannedimagegray(i,startbarcoltemp(i)+1:700) < 125, 1, 'first');
					end
				end
				
				if(isnan(startbarcoltemp(i)))
					startbarcol(i) = NaN;
					endbarcol(i) = NaN;	
				else
					%check if you went too far or if there are no more black pixels remaining to the right
					if( (startbarcoltemp(i) > 700) | (isempty(find(scannedimagegray(i,startbarcoltemp(i):startbarcoltemp(i)+100) < 125, 1, 'last'))))
						startbarcol(i) = NaN;
						endbarcol(i) = NaN;	
					else
						startbarcol(i) = startbarcoltemp(i);
						endbarcol(i) = startbarcol(i)+ find(scannedimagegray(i,startbarcol(i):startbarcol(i)+100) < 125, 1, 'last');
					end
				
					%scrub any black bars that are not at least 30 pixels wide
					if((endbarcol(i) - startbarcol(i)) < 30)
						startbarcol(i) = NaN;
						endbarcol(i) = NaN;
					end
				
					%scrub any black bars that have white pixels within 25 pixels after them
					if (isnan(startbarcol(i)))
						else
						if( isempty(find(scannedimagegray(i,startbarcol(i):startbarcol(i)+25) > 225)))
						else
							startbarcol(i) = NaN;
							endbarcol(i) = NaN;
						end
					end
				end
			end
		end

		%find the middle of each black marker
		middlebarcol = (startbarcol + endbarcol)./2;

		%best fit line to black marker slant
		xpixels = 1:size(scannedimageRGB,1);
		ypixels = 1:size(scannedimageRGB,2);
		slantfit = robustfit(xpixels,middlebarcol);
		
		%plot the best fit line for inspection
		%clf
		%scatter(xpixels,middlebarcol)
		%hold on
		%plot(xpixels,slantfit(2).*xpixels+slantfit(1))

		%find the perpendicular line slope to the robust fit
		if(slantfit(2) == 0 )
		else
			perpfit(2) = -1/slantfit(2);
		end
		
		%if middlebar value is not near the slantfit value, then remove it from middlebar
		for i=1:size(scannedimagegray,1)
			if(middlebarcol(i) - (slantfit(2).*xpixels(i)+slantfit(1)) > 30)
				middlebarcol(i) = NaN;
			end
		end
		
		%find the initial location near the first dark bar along the fit line used for reference
		dim1initial = find(isnan(middlebarcol) == 0, 1, 'first');
		dim2initial = slantfit(2).*xpixels(find(isnan(middlebarcol) == 0, 1, 'first'))+slantfit(1);

		
		%find the topleft corner of the 3rd black box on the top row to use as a stretch/distance measurement
		%numbers determined by looking at images where the 3rd black box at the top is roughly with a buffer on each side
		%start X (j, 2nd coordinate) at round(0.5412 * size(scannedimageRGB,2)) and iterate until round(0.6353 * size(scannedimageRGB,2))
		%start Y (i, 1st coordinate) at round(0.0428 * size(scannedimageRGB,1)) and iterate until round(0.0785 * size(scannedimageRGB,1))
		startX = round(0.5412 * size(scannedimageRGB,2));
		startY = round(0.0428 * size(scannedimageRGB,1));
		iterateX = round(0.6353 * size(scannedimageRGB,2)) - round(0.5412 * size(scannedimageRGB,2));
		iterateY = round(0.0785 * size(scannedimageRGB,1)) - round(0.0428 * size(scannedimageRGB,1));
		rangeX = round(0.0200 * size(scannedimageRGB,2));
		rangeY = round(0.0155 * size(scannedimageRGB,1));

		%3rd black box is found by looking at the color average of the X (horizontal, j: round(0.0200 * size(scannedimageRGB,1)) ) and
		%... Y (vertical, i: round(0.0155 * size(scannedimageRGB,1)) ) pixels following the current pixel 
		%the darkest pixel is chosen as the corner
		for i=1:iterateY
			for j=1:iterateX
				blackshademean(i,j) = mean(mean(scannedimagegray(startY+i:startY+i+rangeY,j+startX:j+startX+rangeX)));
			end
		end
		[dim1blackhortemp dim2blackhortemp] = find(blackshademean == min(min(blackshademean)));
		dim1blackhor = min(dim1blackhortemp) + startY;
		dim2blackhor = min(dim2blackhortemp) + startX;
		%yes, X in matlab on the imshow is the horizontal dimension and Y is the vertical dimension counting downwards

		%find the 10th black bar on the left side of the scantron
		clear blackbar_rowstart
		blackbar_rowstart(1) = 0;
		blackbargap = round(0.0391 * size(scannedimageRGB,1));
		for i=11:length(middlebarcol)-10
			%if the row has a middlebarcol value, if all 3 previous rows and all 3 following rows have middlebarcol values, and it has been at least 210/5500
			%... pixels since the last middlebarcol has been recorded, store a new blackbarrowstart value
			if( (~isnan(middlebarcol(i))) & (sum(isnan(middlebarcol(i-3:i-1))) > 2) & (sum(~isnan(middlebarcol(i+1:i+3))) > 2) )
				if(abs(blackbar_rowstart(end) - i) > blackbargap)
					blackbar_rowstart(end+1) = i;
				end
			end
        end
        
		%remove the artificial blackbarstart = 0 as the first index so we only have values where the black bars actually start then find the spacing between each black bar
		blackbar_rowstart = blackbar_rowstart(2:end);
		for i=1:length(blackbar_rowstart)-1
			blackbar_rowspace(i) = blackbar_rowstart(i+1)-blackbar_rowstart(i);
		end

		badindex = zeros(length(blackbar_rowspace),1);
		for i=1:length(blackbar_rowspace)
			if (abs(blackbar_rowspace(i) - mean(blackbar_rowspace)) > 10)
				badindex(i) = 1;
			end
		end
		blackbar_rowspace = blackbar_rowspace(~logical(badindex));
		dim110thblackbar = blackbar_rowstart(find(abs(blackbar_rowstart - (dim1initial + mean(blackbar_rowspace) * 9)) == min(abs(blackbar_rowstart-(dim1initial + mean(blackbar_rowspace) * 9)))));
		dim210thblackbar = slantfit(2).*dim110thblackbar+slantfit(1);

		%find the diagonal distance between the two black bar locations (to use for scaling the perp and slant size of the image)
		totaldim1movediagonal = (dim110thblackbar - dim1blackhor);
		totaldim2movediagonal = (dim210thblackbar - dim2blackhor);
		perpmovediagonal = (totaldim2movediagonal - totaldim1movediagonal * slantfit(2)) / (perpfit(2) - slantfit(2));
		slantmovediagonal = totaldim1movediagonal - perpmovediagonal;
		distanceperpmovediagonal = sqrt((perpmovediagonal)^2 + (perpmovediagonal*perpfit(2))^2);
		distanceslantmovediagonal = sqrt((slantmovediagonal)^2 + (slantmovediagonal * slantfit(2))^2);
		
		%tvu
		perpscale = distanceperpmovediagonal / templatedistanceperpmovediagonal;
		slantscale = distanceslantmovediagonal / templatedistanceslantmovediagonal;

		%ABCDE offset
		%tvu
		horizontaloffset = templateABoffset * size(scannedimageRGB,2) * perpscale;
		
		%12345 offset
		%tvu
		verticaloffset = template12offset * size(scannedimageRGB,1) * slantscale;

		%0-0 offset for ID
		horizontalIDoffset = templateID00offset * size(scannedimageRGB,2) * perpscale;

		%0-1 offset for ID
		verticalIDoffset = templateID01offset * size(scannedimageRGB,1) * slantscale;
		
		%find the location of the box where student's write their name in case you want to block it out later
		distanceperpmovename =  perpscale*templatedistanceperpmovename;
		distanceslantmovename = slantscale*templatedistanceslantmovename;
		if (perpfit(2) < 0)
			perpmovename = -sqrt(distanceperpmovename^2 / (1+perpfit(2)^2));
		else
			perpmovename = sqrt(distanceperpmovename^2 / (1+perpfit(2)^2));
		end
		slantmovename = sqrt(distanceslantmovename^2 / (1+slantfit(2)^2));
		nameloc(1) = round(dim1initial + perpmovename + slantmovename);
		nameloc(2) = round(dim2initial + perpmovename * perpfit(2) + slantmovename * slantfit(2));
		
		%set up the grid of distances for all of the answers
		%tvu
		for i=1:size(answerkey(1).question,2)
			if(i<31)
				for j=1:numoptions
					distanceperp(i,j) = perpscale*templatedistanceperp(1,1) + horizontaloffset * (j-1);
					distanceslant(i,j) = slantscale*templatedistanceslant(1,1) + verticaloffset * (i-1);
					
					%calculate how much to move in dim-1 along each line based on the total distance that must be travelled on each line to reach the destination
					if (perpfit(2) < 0)
						perpmove(i,j) = -sqrt(distanceperp(i,j)^2 / (1+perpfit(2)^2));
					else
						perpmove(i,j) = sqrt(distanceperp(i,j)^2 / (1+perpfit(2)^2));			
					end

					slantmove(i,j) = sqrt(distanceslant(i,j)^2 / (1+slantfit(2)^2));

					%if wanting to use a pixel location change directly rather than the fit along the slant and perp lines, change the if statement to 1==1
					if (1==2)
						ansloc(1,1) = dim1initial + dimmovetot(1,1,1);
						ansloc(2,1) = round(dim2initial + dimmovetot(2,1,1));
					else
						ansloc(1,i,j) = round(dim1initial + perpmove(i,j) + slantmove(i,j));
						ansloc(2,i,j) = round(dim2initial + perpmove(i,j) * perpfit(2) + slantmove(i,j) * slantfit(2));
					end
				end
			elseif((i>30) && (i<61))
				for j=1:numoptions
					distanceperp(i,j) = perpscale*template31distanceperp(1,1) + horizontaloffset * (j-1);
					distanceslant(i,j) = slantscale*template31distanceslant(1,1) + verticaloffset * (i-31);
					
					%calculate how much to move in dim-1 along each line based on the total distance that must be travelled on each line to reach the destination
					if (perpfit(2) < 0)
						perpmove(i,j) = -sqrt(distanceperp(i,j)^2 / (1+perpfit(2)^2));
					else
						perpmove(i,j) = sqrt(distanceperp(i,j)^2 / (1+perpfit(2)^2));			
					end
            
					slantmove(i,j) = sqrt(distanceslant(i,j)^2 / (1+slantfit(2)^2));
            
					%if wanting to use a pixel location change directly rather than the fit along the slant and perp lines, change the if statement to 1==1
					if (1==2)
						ansloc(1,1) = dim1initial + dimmovetot(1,1,1);
						ansloc(2,1) = round(dim2initial + dimmovetot(2,1,1));
					else
						ansloc(1,i,j) = round(dim1initial + perpmove(i,j) + slantmove(i,j));
						ansloc(2,i,j) = round(dim2initial + perpmove(i,j) * perpfit(2) + slantmove(i,j) * slantfit(2));
					end
				end
			elseif((i>60) && (i<91))
				for j=1:numoptions
					distanceperp(i,j) = perpscale*template61distanceperp(1,1) + horizontaloffset * (j-1);
					distanceslant(i,j) = slantscale*template61distanceslant(1,1) + verticaloffset * (i-61);
					
					%calculate how much to move in dim-1 along each line based on the total distance that must be travelled on each line to reach the destination
					if (perpfit(2) < 0)
						perpmove(i,j) = -sqrt(distanceperp(i,j)^2 / (1+perpfit(2)^2));
					else
						perpmove(i,j) = sqrt(distanceperp(i,j)^2 / (1+perpfit(2)^2));			
					end
            
					slantmove(i,j) = sqrt(distanceslant(i,j)^2 / (1+slantfit(2)^2));
            
					%if wanting to use a pixel location change directly rather than the fit along the slant and perp lines, change the if statement to 1==1
					if (1==2)
						ansloc(1,1) = dim1initial + dimmovetot(1,1,1);
						ansloc(2,1) = round(dim2initial + dimmovetot(2,1,1));
					else
						ansloc(1,i,j) = round(dim1initial + perpmove(i,j) + slantmove(i,j));
						ansloc(2,i,j) = round(dim2initial + perpmove(i,j) * perpfit(2) + slantmove(i,j) * slantfit(2));
					end
				end
			elseif((i>90) && (i<101))
				for j=1:numoptions
					distanceperp(i,j) = perpscale*template91distanceperp(1,1) + horizontaloffset * (j-1);
					distanceslant(i,j) = slantscale*template91distanceslant(1,1) + verticaloffset * (i-61);
					
					%calculate how much to move in dim-1 along each line based on the total distance that must be travelled on each line to reach the destination
					if (perpfit(2) < 0)
						perpmove(i,j) = -sqrt(distanceperp(i,j)^2 / (1+perpfit(2)^2));
					else
						perpmove(i,j) = sqrt(distanceperp(i,j)^2 / (1+perpfit(2)^2));			
					end
            
					slantmove(i,j) = sqrt(distanceslant(i,j)^2 / (1+slantfit(2)^2));
            
					%if wanting to use a pixel location change directly rather than the fit along the slant and perp lines, change the if statement to 1==1
					if (1==2)
						ansloc(1,1) = dim1initial + dimmovetot(1,1,1);
						ansloc(2,1) = round(dim2initial + dimmovetot(2,1,1));
					else
						ansloc(1,i,j) = round(dim1initial + perpmove(i,j) + slantmove(i,j));
						ansloc(2,i,j) = round(dim2initial + perpmove(i,j) * perpfit(2) + slantmove(i,j) * slantfit(2));
					end		
				end
			end
		end

		%set up the grid of distances for key ID
		%tvu
		for i=1:2
			keydistanceperp(i) = perpscale*templatedistanceperpmovekey + horizontaloffset * (i-1);
			keydistanceslant(i) = slantscale*templatedistanceslantmovekey ;
			
			%calculate how much to move in dim-1 along each line based on the total distance that must be travelled on each line to reach the destination
			if (perpfit(2) < 0)
				keyperpmove(i) = -sqrt(keydistanceperp(i)^2 / (1+perpfit(2)^2));
			else
				keyperpmove(i) = sqrt(keydistanceperp(i)^2 / (1+perpfit(2)^2));
			end
			keyslantmove(i) = sqrt(keydistanceslant(i)^2 / (1+slantfit(2)^2));

			%if wanting to use a pixel location change directly rather than the fit along the slant and perp lines, change the if statement to 1==1
			if (1==2)
				keyloc(1,1) = dim1initial + dimmovekeytot(1,1,1);
				keyloc(2,1) = round(dim2initial + dimmovekeytot(2,1,1));
			else
				keyloc(1,i) = round(dim1initial + keyperpmove(i) + keyslantmove(i));
				keyloc(2,i) = round(dim2initial + keyperpmove(i) * perpfit(2) + keyslantmove(i) * slantfit(2));
			end
		end
		
		%set up the grid of distances for all of the student ID numbers
		%tvu
		for i=1:10
			for j=1:10
				IDdistanceperp(i,j) = perpscale*templateIDdistanceperp(1,1) + horizontalIDoffset * (j-1);
				IDdistanceslant(i,j) = slantscale*templateIDdistanceslant(1,1) + verticalIDoffset * (i-1);
				
				%calculate how much to move in dim-1 along each line based on the total distance that must be travelled on each line to reach the destination
				if (perpfit(2) < 0)
					IDperpmove(i,j) = -sqrt(IDdistanceperp(i,j)^2 / (1+perpfit(2)^2));
				else
					IDperpmove(i,j) = sqrt(IDdistanceperp(i,j)^2 / (1+perpfit(2)^2));
				end
				IDslantmove(i,j) = sqrt(IDdistanceslant(i,j)^2 / (1+slantfit(2)^2));

				%if wanting to use a pixel location change directly rather than the fit along the slant and perp lines, change the if statement to 1==1
				if (1==2)
					IDloc(1,1) = dim1initial + dimmoveIDtot(1,1,1);
					IDloc(2,1) = round(dim2initial + dimmoveIDtot(2,1,1));
				else
					IDloc(1,i,j) = round(dim1initial + IDperpmove(i,j) + IDslantmove(i,j));
					IDloc(2,i,j) = round(dim2initial + IDperpmove(i,j) * perpfit(2) + IDslantmove(i,j) * slantfit(2));
				end
			end
		end
		
		%%scrub the answer locations of any teal text to help with determining student answers that were shaded poorly
		%for k=1:50
		%	for ii=1:50
		%		for i=1:size(answerkey(1).question,2)
		%			for j=1:numoptions
		%				if( (double(scannedimageRGB(ansloc(1,i,j)-26+k,ansloc(2,i,j)-25+ii,1)) < 100) && (abs(double(scannedimageRGB(ansloc(1,i,j)-26+k,ansloc(2,i,j)-25+ii,2)) - 165) < 35) && (double(scannedimageRGB(ansloc(1,i,j)-26+k,ansloc(2,i,j)-25+ii,3)) > 185))
		%					scannedimageRGB(ansloc(1,i,j)-26+k,ansloc(2,i,j)-25+ii,1) = 255;
		%					scannedimageRGB(ansloc(1,i,j)-26+k,ansloc(2,i,j)-25+ii,2) = 255;
		%					scannedimageRGB(ansloc(1,i,j)-26+k,ansloc(2,i,j)-25+ii,3) = 255;
		%				end
		%			end
		%		end
		%	end
		%end
		
		%%scrub the student ID locations of any teal text to help with determining student IDs that were shaded poorly
		%for k=1:50
		%	for ii=1:50
		%		for i=1:10
		%			for j=1:10
		%				if( (double(scannedimageRGB(IDloc(1,i,j)-26+k,IDloc(2,i,j)-25+ii,1)) < 100) && (abs(double(scannedimageRGB(IDloc(1,i,j)-26+k,IDloc(2,i,j)-25+ii,2)) - 165) < 35) && (double(scannedimageRGB(IDloc(1,i,j)-26+k,IDloc(2,i,j)-25+ii,3)) > 185))
		%					scannedimageRGB(IDloc(1,i,j)-26+k,IDloc(2,i,j)-25+ii,1) = 255;
		%					scannedimageRGB(IDloc(1,i,j)-26+k,IDloc(2,i,j)-25+ii,2) = 255;
		%					scannedimageRGB(IDloc(1,i,j)-26+k,IDloc(2,i,j)-25+ii,3) = 255;
		%				end
		%			end
		%		end
		%	end
		%end
		
		%%scrub the key ID locations of any teal text to help with determining student IDs that were shaded poorly
		%for k=1:50
		%	for ii=1:50
		%		for i=1:4
		%			if( (double(scannedimageRGB(keyloc(1,i)-26+k,keyloc(2,i)-25+ii,1)) < 100) && (abs(double(scannedimageRGB(keyloc(1,i)-26+k,keyloc(2,i)-25+ii,2)) - 165) < 35) && (double(scannedimageRGB(keyloc(1,i)-26+k,keyloc(2,i)-25+ii,3)) > 185))
		%				scannedimageRGB(keyloc(1,i)-26+k,keyloc(2,i)-25+ii,1) = 255;
		%				scannedimageRGB(keyloc(1,i)-26+k,keyloc(2,i)-25+ii,2) = 255;
		%				scannedimageRGB(keyloc(1,i)-26+k,keyloc(2,i)-25+ii,3) = 255;
		%			end
		%		end
		%	end
		%end
		
		scannedimagegrayscrubbed = rgb2gray(scannedimageRGB);
		
		%determine what the students answers are
		for i=1:size(answerkey(1).question,2)
			for j=1:numoptions
				anscolors(i,j) = mean(mean(scannedimagegrayscrubbed(ansloc(1,i,j)-25:ansloc(1,i,j)+25,ansloc(2,i,j)-25:ansloc(2,i,j)+25,1)));
			end
			if (sum(anscolors(i,:)<100) >1)
				iii
				flag_multipleans(iii) = 1;
			end
		end
		
		%determine which answer key is needed
		for i=1:2
			keycolors(i) = mean(mean(scannedimagegrayscrubbed(keyloc(1,i)-25:keyloc(1,i)+25,keyloc(2,i)-25:keyloc(2,i)+25,1)));
		end
		
		if(str2num(cell2mat(promptans_numanskeys)) == 1)
			keyselected (iii) = 1;
		else
			keyselected(iii) = find(keycolors == min(keycolors));
		end

		grade(iii) = 0;
		for i=1:size(answerkey(keyselected(iii)).question,2)
			if(min(anscolors(i,:)) <190)
				corstudentans(iii,i) = find(anscolors(find(answerkey(keyselected(iii)).cor == i),:) == min(anscolors(find(answerkey(keyselected(iii)).cor == i),:)));
			else
				corstudentans(iii,i) = NaN;
            end
            
			if((corstudentans(iii,i) == answerkey(1).answer(i)) | (answerkey(1).answer(i) == 6))
				grade(iii) = grade(iii)+1;
			end
		end

		%determine what the students ID is
		for i=1:10
			for j=1:10
				IDcolors(i,j) = mean(mean(scannedimagegrayscrubbed(IDloc(1,i,j)-25:IDloc(1,i,j)+25,IDloc(2,i,j)-25:IDloc(2,i,j)+25,1)));
			end
		end

		studentIDstr = '';
		for j=1:10
			if(min(IDcolors(:,j)) <190)
				studentID(j) = find(IDcolors(:,j) == min(IDcolors(:,j)))-1;
				studentIDstr = strcat(studentIDstr,num2str(studentID(j)));
			else
				studentID(j) = NaN;
			end
		end
		studentIDstored(iii) = string(studentIDstr)
		
		%display the initial location, special black bar locations, and the grid of answer locations (in red) and correct answers (in green)
		%no longer display the stretch calibration location at the D at the bottom right,
		for k=1:size(answerkey(1).question,2)
			for ii=1:numoptions
				for i=1:25
					for j=1:25
						if (round(dim2initial) < 12)
							warningdim2 = 1;
						else
							scannedimageRGB(dim1initial-13+i,round(dim2initial)-13+j,1) = 255;
							scannedimageRGB(dim1initial-13+i,round(dim2initial)-13+j,2)= 0;
							scannedimageRGB(dim1initial-13+i,round(dim2initial)-13+j,3) = 0;
						end
						%scannedimageRGB(dim1teal-13+i,round(dim2teal)-13+j,1) = 255;
						%scannedimageRGB(dim1teal-13+i,round(dim2teal)-13+j,2)= 0;
						%scannedimageRGB(dim1teal-13+i,round(dim2teal)-13+j,3) = 0;
						scannedimageRGB(dim1blackhor-13+i,round(dim2blackhor)-13+j,1) = 255;
						scannedimageRGB(dim1blackhor-13+i,round(dim2blackhor)-13+j,2)= 0;
						scannedimageRGB(dim1blackhor-13+i,round(dim2blackhor)-13+j,3) = 0;
						scannedimageRGB(dim110thblackbar-13+i,round(dim210thblackbar)-13+j,1) = 255;
						scannedimageRGB(dim110thblackbar-13+i,round(dim210thblackbar)-13+j,2)= 0;
						scannedimageRGB(dim110thblackbar-13+i,round(dim210thblackbar)-13+j,3) = 0;
						for jj=1:2
							keyloc(1,jj)-13+i;
							round(keyloc(2,jj))-13+j;
							scannedimageRGB(keyloc(1,jj)-13+i,round(keyloc(2,jj))-13+j,1) = 255;
							scannedimageRGB(keyloc(1,jj)-13+i,round(keyloc(2,jj))-13+j,2)= 0;
							scannedimageRGB(keyloc(1,jj)-13+i,round(keyloc(2,jj))-13+j,3) = 0;
						end
						if(answerkey(keyselected(iii)).answer(k) == ii)
							scannedimageRGB(ansloc(1,k,ii)-13+i,ansloc(2,k,ii)-13+j,1) = 0;
							scannedimageRGB(ansloc(1,k,ii)-13+i,ansloc(2,k,ii)-13+j,2)= 255;
							scannedimageRGB(ansloc(1,k,ii)-13+i,ansloc(2,k,ii)-13+j,3) = 0;
						else
							scannedimageRGB(ansloc(1,k,ii)-13+i,ansloc(2,k,ii)-13+j,1) = 255;
							scannedimageRGB(ansloc(1,k,ii)-13+i,ansloc(2,k,ii)-13+j,2)= 0;
							scannedimageRGB(ansloc(1,k,ii)-13+i,ansloc(2,k,ii)-13+j,3) = 0;
						end
					end
				end
			end
		end
		
		if(warningdim2 ==1)
			warning('round(dim2initial) is too close to the edge (< 12 pixels)')
		end
		
		%display the student ID locations
		for k=1:10
			for ii=1:10
				for i=1:25
					for j=1:25
						scannedimageRGB(IDloc(1,k,ii)-13+i,IDloc(2,k,ii)-13+j,1) = 255;
						scannedimageRGB(IDloc(1,k,ii)-13+i,IDloc(2,k,ii)-13+j,2)= 0;
						scannedimageRGB(IDloc(1,k,ii)-13+i,IDloc(2,k,ii)-13+j,3) = 0;
					end
				end
			end
		end
		
		%%blur out the student's name
		%for i=1:601
		%	for j=1:1501
		%		scannedimageRGB(nameloc(1)-301+i,nameloc(2)-751+j,1) = 0;
		%		scannedimageRGB(nameloc(1)-301+i,nameloc(2)-751+j,2) = 0;
		%		scannedimageRGB(nameloc(1)-301+i,nameloc(2)-751+j,3) = 0;
		%	end
		%end
		
		iptsetpref('ImshowAxesVisible','on');
		plotting = figure;
		imshow(scannedimageRGB)
		
		%print a jpg of the 
		fileoutputname = strcat('Processed/',studentIDstored(iii),'.jpg');
		print(plotting,char(fileoutputname),'-djpeg');
		
		%close the figure
		close(plotting);
	end
end

set(handles.pushbutton1,'string','Grade Quizzes!!!','enable','on','BackgroundColor','green');

%for each student in the roster, find their matching ID and assign them the grade associated with that ID
usedID = zeros(numfiles,1);
usedRosterID = zeros(size(studentRosterVal{1},1),1);
rostergrade = zeros(size(studentRosterVal{1},1),1);
for i=1:size(studentRosterVal{1})
	if(any(string(studentRosterVal{3}(i)) == studentIDstored))
		if(justparticipation==1)
			rostergrade(i) = 1;
		else
			rostergrade(i) = grade(find(studentIDstored == string(studentRosterVal{3}(i))));
		end
		usedID(find(studentIDstored == string(studentRosterVal{3}(i)))) = 1;
		usedRosterID(i)= 1;
	end
end

%print any unused IDs and their corresponding grade so that their grade can be manually entered
for iii=1:numfiles
	if(usedID(iii) == 0)
		iii
		studentIDstored(iii)
		grade(iii)
		
		filewitherrorname = strcat('Processed/',studentIDstored(iii),'.jpg')
		filewitherror = imread(char(filewitherrorname));
		errorplotting(iii) = figure;
		imshow(filewitherror)
		
		%missingIDchars(iii,:) = char(studentIDstored(iii));

		%%try to match the student's inputted ID with the IDs on the roster based on matching from the front and end of the strings
		%for i=1:length(missingIDchars(iii,:))
		%	matchingIDportionfront{iii,i} = strfind(string(studentRosterVal{3}),missingIDchars(iii,1:end+1-i));
		%	matchingIDportionend{iii,i} = strfind(string(studentRosterVal{3}),missingIDchars(iii,i:end));

		%	%isempty(cell2mat(matchingIDportionfront{iii,i}))
		%	%isempty(cell2mat(matchingIDportionend{iii,i}))
		%	
		%end
		
		%choose the best match by finding the longest match from the front and the back
	end
end

%print student roster last name (alphabetically), score, and student ID into text file that can go directly into Microsoft Excel, 
fileID = fopen('quizgrades.out','w');
for i=1:size(studentRosterVal{1})
	fprintf(fileID,'%s,',string(studentRosterVal{1}(i)));
	fprintf(fileID,'%d,',rostergrade(i));
	fprintf(fileID,'%s\n',string(studentRosterVal{3}(i)));
end
fclose(fileID);

	if(ispc)
		%print to Excel
		excelFileName = 'quizgrades.xlsx';
		excelPrintCell = cellstr([string(studentRosterVal{1}(:)),rostergrade(:),string(studentRosterVal{3}(:))]);
		delete 'quizgrades.xlsx';
		xlswrite(excelFileName,excelPrintCell);
	elseif(isunix)
		%skip print to Excel
	else
		error('Don''t recognize the operating system when trying to print to Excel')
	end

%Statistics stuff

meangrade = mean(grade)
mediangrade = median(grade)
modegrade = mode(grade)
standarddeviationgrade = std(grade)

%number of questions left blank by students in total
totalunansweredquestions = sum(sum(isnan(corstudentans)))
	
%number of people that got each question right
numcorrect = zeros(size(answerkey(1).question,2),1);	
for iii=1:numfiles	
	for i=1:size(answerkey(1).question,2)	
		if(corstudentans(iii,i) == answerkey(1).answer(i))	
			numcorrect(i) = numcorrect(i) + 1;	
		end	
	end	
end
%fraction of people that got each question right	
fractioncorrect = numcorrect./numfiles

%distribution of answers for the most commonly missed question
histc(corstudentans(:,find(numcorrect == min(numcorrect))),1:5);

%distribution of answers for each question	
histofall = histc(corstudentans,1:5)

%print statistics to output file
fileID = fopen('statistics.out','w');

%print the mean, median, mode, and standard deviation to file
fprintf(fileID,'The total number of quizzes inputted is %s.\n',string(numfiles));
%num questions
fprintf(fileID,'Note that all statistics following this are calculated using only these files, but it does include any files that were not measured correctly, so if there are any errors the statistics will be slightly biased.\n');
fprintf(fileID,'The mean grade is %s.\n',string(meangrade));
meangradefrac = meangrade/size(answerkey(1).question,2);
fprintf(fileID,'The mean grade as a fraction is %s.\n',string(meangradefrac));
fprintf(fileID,'The median grade is %s.\n',string(mediangrade));
fprintf(fileID,'The mode grade is %s.\n',string(modegrade));
fprintf(fileID,'The standard deviation of the grades is %s.\n\n',string(standarddeviationgrade));


%give number of questions on side here
%print other statistics
fprintf(fileID,'The number of blanks that students left is %s.\n',string(totalunansweredquestions));
fprintf(fileID,'Fraction of students that got each question correct: \n');
for i=1:size(fractioncorrect,1)
         fprintf(fileID,'%d %0.2f ',[i fractioncorrect(i)]);
     fprintf(fileID,'\n');
end

%print histogram of all student responses to each question to the statistics.out file
fprintf(fileID,'Histogram of students that answered A-E (vertical axis) for each question (horizontal axis) \n');
for i=0:size(histofall,1)	
	fprintf(fileID,'%d\t',i);
    for j=1:size(histofall,2)
			if(i==0)
				if(j==1)
					fprintf(fileID,'%d\t',j);
				else
					fprintf(fileID,'%d\t',j);
				end
			else
			    fprintf(fileID,'%d\t',histofall(i,j));
			end
    end
    fprintf(fileID,'\n');
end

%print the >90%, >80%, etc. brackets
%size(answerkey,2)
percentgrade = grade./size(answerkey(1).question,2);
studentsin90thpercentile = sum(((percentgrade >= 0.9) & (percentgrade < 1.01)));
studentsin80thpercentile = sum(((percentgrade >= 0.8) & (percentgrade < 0.9)));
studentsin70thpercentile = sum(((percentgrade >= 0.7) & (percentgrade < 0.8)));
studentsin60thpercentile = sum(((percentgrade >= 0.6) & (percentgrade < 0.7)));
studentsin50thpercentile = sum(((percentgrade >= 0.5) & (percentgrade < 0.6)));
studentsin0thpercentile = sum(((percentgrade >= 0.00) & (percentgrade < 0.5)));

fprintf(fileID,'The number of students who scored between 90 to 100 percent is %s.\n',string(studentsin90thpercentile));
fprintf(fileID,'The number of students who scored between 80 to 89.9 percent is %s.\n',string(studentsin80thpercentile));
fprintf(fileID,'The number of students who scored between 70 to 79.9 percent is %s.\n',string(studentsin70thpercentile));
fprintf(fileID,'The number of students who scored between 60 to 69.9 percent is %s.\n',string(studentsin60thpercentile));
fprintf(fileID,'The number of students who scored between 50 to 59.9 percent is %s.\n',string(studentsin50thpercentile));
fprintf(fileID,'The number of students who scored between 0 to 49.9 percent is %s.\n',string(studentsin0thpercentile));
fprintf(fileID,'\n');


%pearson statistic thing.
stddevpb = sqrt(1/numfiles .* sum((grade - meangrade).^2));
for i=1:size(answerkey(1).question,2)
	n1(i) = sum(corstudentans(:,i) == answerkey(1).answer(i));
	n0(i) = numfiles - n1(i);
	M1(i) = mean(grade(corstudentans(:,i) == answerkey(1).answer(i)));
	M0(i) = mean(grade(corstudentans(:,i) ~= answerkey(1).answer(i)));
	rpb(i) = (M1(i) - M0(i))./stddevpb .* sqrt(n1(i)*n0(i)/(numfiles.^2));
	fprintf(fileID,'The Point-biserial correlation coefficient for question %d is %0.3f.\n',[i rpb(i)]);
end


fclose(fileID);

if(exist('flag_multipleans')==1)
    flag_multipleans
end

%end timer
toc

%go back to initial directory at end of push button so that the next push button can be called
cd(initialWD);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%TEMPLATE VALUE CREATION CODE%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %change the name of the file you read in and make sure you are in the correct directory, then edit the particular locations of the values you are setting up the template for at the end
% iii=1
% clearvars scannedimageRGB scannedimagegray startbarcol endbarcol startbarcoltemp middlebarcol xpixels ypixels slantfit perpfit dim1initial dim2initial distanceteal dim1teal dim2teal totaldim1moveteal totaldim2moveteal perpmoveteal slantmoveteal distanceperpmoveteal distanceslantmoveteal perpscale slantscale horizontaloffset verticaloffset horizontalIDoffset verticalIDoffset distanceperpmovename distanceslantmovename perpmovename slantmovename nameloc distanceperp distanceslant perpmove slantmove ansloc IDdistanceperp IDdistanceslant IDperpmove IDslantmove IDloc anscolors IDcolors studentID studentIDstr plotting

% %warnings initialized
% warningdim2 = 0;

% %%%%%Make sure to fill in template values if using a different template for the scantron;
% templatedimmovetot(1,1,1) = 398;
% templatedimmovetot(2,1,1) = 249.1946;
% templatedistanceperp(1,1) = 252.0843;
% templatedistanceslant(1,1) = 396.1761;
% templateIDdimmovetot(1,1,1) = 2842;
% templateIDdimmovetot(2,1,1) = 1.5672e+03;
% templateIDdistanceperp(1,1) = 1.5878e+03;
% templateIDdistanceslant(1,1) = 2.8305e+03;
% templatedistanceperpmoveteal = 2.4139e+03;
% templatedistanceslantmoveteal = 5.1716e+03;
% templatedistanceperpmovename = 1.0e+03;
% templatedistanceslantmovename = 4.8e+03;

% %read all file names and iterate over all of them
% scannedimageRGB = imread('001.jpg');

% %create a grayscale version of the image
% scannedimagegray = rgb2gray(scannedimageRGB);

% iptsetpref('ImshowAxesVisible','on');
% plotting = figure;
% imshow(scannedimageRGB)
		
% %find the start and end of the black bar in each row
% for i=1:size(scannedimagegray,1)
	% %maybe use this to make an improvement
	% %&(scannedimageRGB(i,1:700,1)-scannedimagegray(i,1:700,2) < 5
	% %make sure to ignore rows with no black markers, otherwise find the start and end pixels of the black marker for that row
	% if(isempty(find(scannedimagegray(i,1:700) < 50, 1, 'first')))
		% startbarcol(i) = NaN;
		% endbarcol(i) = NaN;
	% else
		% startbarcoltemp(i) = find(scannedimagegray(i,1:700) < 50, 1, 'first');
		
		% %scrub any black pixels that don't have a white pixel before them within 10 pixels
		% while(not(any(scannedimagegray(i,startbarcoltemp(i)-10:startbarcoltemp(i)-1) > 240)))
			% if(isempty(find(scannedimagegray(i,startbarcoltemp(i)+1:700) < 50, 1, 'first')))
				% startbarcoltemp(i) = NaN;
				% break
			% else
				% startbarcoltemp(i) = startbarcoltemp(i)+ find(scannedimagegray(i,startbarcoltemp(i)+1:700) < 50, 1, 'first');
			% end
		% end
		
		% if(isnan(startbarcoltemp(i)))
			% startbarcol(i) = NaN;
			% endbarcol(i) = NaN;	
		% else
			% %check if you went too far or if there are no more black pixels remaining to the right
			% if( (startbarcoltemp(i) > 700) | (isempty(find(scannedimagegray(i,startbarcoltemp(i):startbarcoltemp(i)+100) < 50, 1, 'last'))))
				% startbarcol(i) = NaN;
				% endbarcol(i) = NaN;	
			% else
				% startbarcol(i) = startbarcoltemp(i);
				% endbarcol(i) = startbarcol(i)+ find(scannedimagegray(i,startbarcol(i):startbarcol(i)+100) < 50, 1, 'last');
			% end
		
			% %scrub any black bars that are not at least 30 pixels wide
			% if((endbarcol(i) - startbarcol(i)) < 30)
				% startbarcol(i) = NaN;
				% endbarcol(i) = NaN;
			% end
		
			% %scrub any black bars that have white pixels within 25 pixels after them
			% if (isnan(startbarcol(i)))
				% else
				% if( isempty(find(scannedimagegray(i,startbarcol(i):startbarcol(i)+25) > 225)))
				% else
					% startbarcol(i) = NaN;
					% endbarcol(i) = NaN;
				% end
			% end
		% end
	% end
% end

% %find the middle of each black marker
% middlebarcol = (startbarcol + endbarcol)./2;

% %best fit line to black marker slant
% xpixels = 1:size(scannedimageRGB,1);
% ypixels = 1:size(scannedimageRGB,2);
% slantfit = robustfit(xpixels,middlebarcol);

% %plot the best fit line for inspection
% %clf
% %scatter(xpixels,middlebarcol)
% %hold on
% %plot(xpixels,slantfit(2).*xpixels+slantfit(1))

% %find the perpendicular line slope to the robust fit
% if(slantfit(2) == 0 )
% else
	% perpfit(2) = -1/slantfit(2);
% end

% %if middlebar value is not near the slantfit value, then remove it from middlebar
% for i=1:size(scannedimagegray,1)
	% if(middlebarcol(i) - (slantfit(2).*xpixels(i)+slantfit(1)) > 30)
		% middlebarcol(i) = NaN;
	% end
% end

% %find the initial location near the first dark bar along the fit line used for reference
% dim1initial = find(isnan(middlebarcol) == 0, 1, 'first');
% dim2initial = slantfit(2).*xpixels(find(isnan(middlebarcol) == 0, 1, 'first'))+slantfit(1);

% %ENTER TEMPLATE VALUES HERE AS YOU LOOK AT IMAGE
% %find 26 A:  1055 (dim2)  616 (dim1)
% dim1_26A = 616;
% dim2_26A = 1055;
% template26dimmovetot(1,1,1) = dim1_26A - dim1initial;
% template26dimmovetot(2,1,1) = dim2_26A - dim2initial;
% template26perpmove(1,1) = (template26dimmovetot(2,1,1) - slantfit(2) * template26dimmovetot(1,1,1)) /(perpfit(2) - slantfit(2));
% template26slantmove(1,1) = templatedimmovetot(1,1,1) - template26perpmove(1,1);
% template26distanceperp(1,1) = sqrt((template26perpmove(1,1))^2 + (template26perpmove(1,1)*perpfit(2))^2)
% template26distanceslant(1,1) =  sqrt((template26slantmove(1,1))^2 + (template26slantmove(1,1)*slantfit(2))^2)


% dim1_1A = 549;
% dim2_1A = 388;
% templatedimmovetot(1,1,1) = dim1_1A - dim1initial
% templatedimmovetot(2,1,1) = dim2_1A - dim2initial
% templateperpmove(1,1) = (templatedimmovetot(2,1,1) - slantfit(2) * templatedimmovetot(1,1,1)) /(perpfit(2) - slantfit(2));
% templateslantmove(1,1) = templatedimmovetot(1,1,1) - templateperpmove(1,1);
% templatedistanceperp(1,1) = sqrt((templateperpmove(1,1))^2 + (templateperpmove(1,1)*perpfit(2))^2)
% templatedistanceslant(1,1) =  sqrt((templateslantmove(1,1))^2 + (templateslantmove(1,1)*slantfit(2))^2)


% %%find studentID 0: 1706 (dim2) 2993 (dim1)
% dimID1_00 = 2993;
% dimID2_00 = 1706;
% templateIDdimmovetot(1,1,1) = dimID1_00 - dim1initial
% templateIDdimmovetot(2,1,1) = dimID2_00 - dim2initial
% templateIDperpmove(1,1) = (templateIDdimmovetot(2,1,1) - slantfit(2) * templateIDdimmovetot(1,1,1)) /(perpfit(2) - slantfit(2));
% templateIDslantmove(1,1) = templateIDdimmovetot(1,1,1) - templateIDperpmove(1,1);
% templateIDdistanceperp(1,1) = sqrt((templateIDperpmove(1,1))^2 + (templateIDperpmove(1,1)*perpfit(2))^2)
% templateIDdistanceslant(1,1) =  sqrt((templateIDslantmove(1,1))^2 + (templateIDslantmove(1,1)*slantfit(2))^2)

% %Teal

		% %find the bottomright corner's teal text based on maximal distance of a teal text from diminitial
		% distanceteal = zeros(size(scannedimageRGB,1),size(scannedimageRGB,2));
		% for i=size(scannedimageRGB,1)-1500:size(scannedimageRGB,1)
			% for j=size(scannedimageRGB,2)-2000:size(scannedimageRGB,2)
				% if( (abs(double(scannedimageRGB(i,j,1))- 25) < 65) && (abs(double(scannedimageRGB(i,j,2)) - 160) < 65) && (abs(double(scannedimageRGB(i,j,3)) - 200) < 65) )
				% %if( (abs(im2double(scannedimageRGB(i,j,1))*255 - 25) < 65) && (abs(im2double(scannedimageRGB(i,j,2))*255 - 160) < 65) && (abs(im2double(scannedimageRGB(i,j,3))*255 - 200) < 65) )
					% distanceteal(i,j) = sqrt((i-dim1initial)^2 + (j-dim2initial)^2);
				% end
			% end
		% end

% [dim1teal dim2teal] = ind2sub(size(distanceteal), find(distanceteal == max(max(distanceteal))));

% totaldim1moveteal = (dim1teal - dim1initial);
% totaldim2moveteal = (dim2teal - dim2initial);
% perpmoveteal = (totaldim2moveteal - totaldim1moveteal * slantfit(2)) / (perpfit(2) - slantfit(2));
% slantmoveteal = totaldim1moveteal - perpmoveteal;
% distanceperpmoveteal = sqrt((perpmoveteal)^2 + (perpmoveteal*perpfit(2))^2);
% distanceslantmoveteal = sqrt((slantmoveteal)^2 + (slantmoveteal * slantfit(2))^2);

% %name
% dim1_1Aname = 4946;
% dim2_1Aname = 1073;
% templatedimmovetotname(1,1,1) = dim1_1Aname - dim1initial
% templatedimmovetotname(2,1,1) = dim2_1Aname - dim2initial
% templateperpmovename(1,1) = (templatedimmovetotname(2,1,1) - slantfit(2) * templatedimmovetotname(1,1,1)) /(perpfit(2) - slantfit(2));
% templateslantmovename(1,1) = templatedimmovetotname(1,1,1) - templateperpmovename(1,1);
% templatedistanceperpname(1,1) = sqrt((templateperpmovename(1,1))^2 + (templateperpmovename(1,1)*perpfit(2))^2)
% templatedistanceslantname(1,1) =  sqrt((templateslantmovename(1,1))^2 + (templateslantmovename(1,1)*slantfit(2))^2)





% %%show the slantfit on the RGB image as a test
% for i=1:size(scannedimageRGB,1)
	% scannedimageRGB(i,round(slantfit(2).*xpixels(i)+slantfit(1)),1) = 240;
	% scannedimageRGB(i,round(slantfit(2).*xpixels(i)+slantfit(1)),2) = 0  ;
	% scannedimageRGB(i,round(slantfit(2).*xpixels(i)+slantfit(1)),3) = 0  ;
% end
% iptsetpref('ImshowAxesVisible','on');
% figure
% imshow(scannedimageRGB)


% templatedistanceperp(1,1) = 252.0843;
% templatedistanceslant(1,1) = 396.1761;

% if (perpfit(2) < 0)
	% perpmove(1,1) = -sqrt(templatedistanceperp(1,1)^2 / (1+perpfit(2)^2));
% else
	% perpmove(1,1) = sqrt(templatedistanceperp(1,1) ^2 / (1+perpfit(2)^2));			
% end

% slantmove(1,1) = sqrt(templatedistanceslant(1,1)^2 / (1+slantfit(2)^2));

% ansloc(1,1,1) = round(dim1initial + perpmove(1,1) + slantmove(1,1));
% ansloc(2,1,1) = round(dim2initial + perpmove(1,1) * perpfit(2) + slantmove(1,1) * slantfit(2));

% for i=1:50
	% for j=1:50
		% scannedimageRGB(ansloc(1,1,1)-25+i,ansloc(2,1,1)-25+j,1) = 0;
		% scannedimageRGB(ansloc(1,1,1)-25+i,ansloc(2,1,1)-25+j,2)= 0;
		% scannedimageRGB(ansloc(1,1,1)-25+i,ansloc(2,1,1)-25+j,3) = 255;
	% end
% end

% iptsetpref('ImshowAxesVisible','on');
% figure
% imshow(scannedimageRGB)







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%OLD CODE%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%
		%%%%Make sure to fill in template values if using a different template for the scantron;
		% templatedimmovetot(1,1,1) = 398;
		% templatedimmovetot(2,1,1) = 249.1946;
		% templatedistanceperp(1,1) = 252.0843;
		% templatedistanceslant(1,1) = 396.1761;
		% templateIDdimmovetot(1,1,1) = 2842;
		% templateIDdimmovetot(2,1,1) = 1.5672e+03;
		% templateIDdistanceperp(1,1) = 1.5878e+03;
		% templateIDdistanceslant(1,1) = 2.8305e+03;
		% templatedistanceperpmoveteal = 2.4139e+03;
		% templatedistanceslantmoveteal = 5.1716e+03;
		% templatedistanceperpmovename = 1.0e+03;
		% templatedistanceslantmovename = 4.8e+03;
		% template26distanceperp = 919.6143;
		% template26distanceslant = 391.3396;
%%%




%%%
		%code to find the template values
		%calibrate locations with measured coordinates on template
		%find 1 A: 388 (dim2) 549 (dim1)
		%dim1_1A = 549;
		%dim2_1A = 388;
		%templatedimmovetot(1,1,1) = dim1_1A - dim1initial;
		%templatedimmovetot(2,1,1) = dim2_1A - dim2initial;
		%templateperpmove(1,1) = (templatedimmovetot(2,1,1) - slantfit(2) * templatedimmovetot(1,1,1)) /(perpfit(2) - slantfit(2));
		%templateslantmove(1,1) = templatedimmovetot(1,1,1) - templateperpmove(1,1);
		%templatedistanceperp(1,1) = sqrt((templateperpmove(1,1))^2 + (templateperpmove(1,1)*perpfit(2))^2);
		%templatedistanceslant(1,1) =  sqrt((templateslantmove(1,1))^2 + (templateslantmove(1,1)*slantfit(2))^2);
		%%find studentID 0: 1706 (dim2) 2993 (dim1)
		%dimID1_00 = 2993;
		%dimID2_00 = 1706;
		%templateIDdimmovetot(1,1,1) = dimID1_00 - dim1initial;
		%templateIDdimmovetot(2,1,1) = dimID2_00 - dim2initial;
		%templateIDperpmove(1,1) = (templateIDdimmovetot(2,1,1) - slantfit(2) * templateIDdimmovetot(1,1,1)) /(perpfit(2) - slantfit(2));
		%templateIDslantmove(1,1) = templateIDdimmovetot(1,1,1) - templateIDperpmove(1,1);
		%templateIDdistanceperp(1,1) = sqrt((templateIDperpmove(1,1))^2 + (templateIDperpmove(1,1)*perpfit(2))^2);
		%templateIDdistanceslant(1,1) =  sqrt((templateIDslantmove(1,1))^2 + (templateIDslantmove(1,1)*slantfit(2))^2);
		%find 26 A:  1055 (dim2)  616 (dim1)
		%dim1_26A = 1055;
		%dim2_26A = 616;
		%template26dimmovetot(1,1,1) = dim1_26A - dim1initial;
		%template26dimmovetot(2,1,1) = dim2_26A - dim2initial;
		%template26perpmove(1,1) = (template26dimmovetot(2,1,1) - slantfit(2) * template26dimmovetot(1,1,1)) /(perpfit(2) - slantfit(2));
		%template26slantmove(1,1) = templatedimmovetot(1,1,1) - template26perpmove(1,1);
		%template26distanceperp(1,1) = sqrt((template26perpmove(1,1))^2 + (template26perpmove(1,1)*perpfit(2))^2)
		%template26distanceslant(1,1) =  sqrt((template26slantmove(1,1))^2 + (template26slantmove(1,1)*slantfit(2))^2)
%%%

%%%
%dlmwrite('statistics.out',fractioncorrect','-append','delimiter','\t','precision','%.2f');
%dlmwrite('statistics.out',histofall,'-append','delimiter','\t');
%%%

%%%
%fprintf(fileID, [repmat(' %3.3f ', size(fractioncorrect,1), size(fractioncorrect,2)) repmat('\n',size(fractioncorrect,1),1)], fractioncorrect')
%fprintf(fileID, [repmat(' %d ', size(histofall,1), size(histofall,2)) repmat('\n',size(histofall,1),1)], histofall')
%%%


%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%SELECT WORKING DIRECTORY%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% --- Executes on button press in pushbutton7.
%function pushbutton7_Callback(hObject, eventdata, handles)
%% hObject    handle to pushbutton7 (see GCBO)
%% eventdata  reserved - to be defined in a future version of MATLAB
%% handles    structure with handles and user data (see GUIDATA)
%
%global fileWD
%
%[fileName,fileWD,fileind] = uigetfile('*.pdf','MultiSelect','on');
%cd(fileWD)
%%%


%%%
%GSOutputName1 = 'Originaljpgs/Batch1_%03d.jpg';
%GSInputName1 = 'Batch1.pdf';
%GSOutputName2 = 'Originaljpgs/Batch2_%03d.jpg';
%GSInputName2 = 'Batch2.pdf';
%GSOutputName3 = 'Originaljpgs/Batch3_%03d.jpg';
%GSInputName3 = 'Batch3.pdf';
%
%GSsystemstring1 = [GSPath,' -dSAFER -dBATCH -dNOPAUSE -sDEVICE=jpeg -r500 -sOutputFile=',GSOutputName1,' ',GSInputName1];
%GSsystemstring2 = [GSPath,' -dSAFER -dBATCH -dNOPAUSE -sDEVICE=jpeg -r500 -sOutputFile=',GSOutputName2,' ',GSInputName2];
%GSsystemstring3 = [GSPath,' -dSAFER -dBATCH -dNOPAUSE -sDEVICE=jpeg -r500 -sOutputFile=',GSOutputName3,' ',GSInputName3];
%
%system(GSsystemstring1);
%system(GSsystemstring2);
%system(GSsystemstring3);
%C:\Users\Cbilinski\Dropbox\Astrophysics\Teaching\2017_Spring_ASTR170\GradingCode\Code
%%%


%%%
%%match the student IDs with the class roster names and IDs
%used = zeros(numfiles,1);
%for iii=1:numfiles
%	if(any(studentIDstored(iii) == string(studentRosterVal{3})))
%		studentLastNameStored(iii) = string(studentRosterVal{1}(find(studentIDstored(iii) == string(studentRosterVal{3}))));
%		studentFirstNameStored(iii) = string(studentRosterVal{2}(find(studentIDstored(iii) == string(studentRosterVal{3}))));
%		usedID(iii) = 1;
%	end
%end
%
%%find any unused student IDs and try to match them to the most likely student ID
%%for iii=1:numfiles
%%	if(usedID(iii) == 0)
%%		iii
%%		usedID(iii)
%%		grade(iii)
%%	end
%%end
%
%%sort (alphabetically by last name) the used student IDs/names with their grades to prepare for printing
%[studentLastNameStored_sorted,index_alphabeticalSort] = sort(studentLastNameStored);
%
%grade_sorted = grade(index_alphabeticalSort);
%studentIDstored_sorted = studentIDstored(index_alphabeticalSort);
%
%for iii=1:numfiles
%	if(ismissing(studentLastNameStored_sorted(iii)))
%		studentLastNameStored_sorted(iii) = 'NoMatchName';
%	end
%end
%
%%print student name and score alphabetically into text file that can go directly into Microsoft Excel, and also print any unused student IDs and their grades
%fileID = fopen('quizgrades.out','w');
%for iii=1:numfiles
%	fprintf(fileID,'%s ',studentLastNameStored_sorted(iii));
%	fprintf(fileID,'%d ',grade_sorted(iii));
%	fprintf(fileID,'%s\n',studentIDstored_sorted(iii));
%end
%fclose(fileID);
%%%%











%%%
%fileID = fopen('quizgrades.out','w');
%for iii=1:numfiles
%	fprintf(fileID,'%8s ',studentIDstored(iii));
%	fprintf(fileID,'%d\n',grade(iii));
%end
%fclose(fileID);
%%%



%%%
		%clearvars -except handles.pushbutton1 studentIDstored grade studentans filenames numfiles iii answerkey numoptions templatedimmovetot templatedistanceperp templatedistanceslant templateIDdimmovetot templateIDdistanceperp templateIDdistanceslant templatedistanceperpmoveteal templatedistanceslantmoveteal templatedistanceperpmovename templatedistanceslantmovename
%%%

%%%
%%list all answer keys available and ask which one to use
%ls ../AnswerKeys
%answerkeyname = input('Which answer key do you want to use?  If none, type "new" [new]\n','s');

%%if no input, assume you want a new answer key
%if isempty(answerkeyname)
%    answerkeyname = 'new';
%end

%if(strcmp(answerkeyname, 'new'))
%	%create a new answer key based on user input and store it
%	numquestions = str2num(input('How many questions? (1-50)\n', 's'));
%	for i=1:numquestions	
%		i
%		answerprompt(i,:) = {['Answer to question ',num2str(i),'? (1-5 :: A-E)\n']};
%		answerkey(i) = input(char(answerprompt(i,:)))
%	end
%	yearseason = input('What year and season? Don''t put any spaces between the year and season, and spell the season out entirely (summer, fall, winter, spring) [2017spring]\n', 's');
%	quiznumber = input('Which quiz? (1-5)\n', 's');
%	
%	answerkeyname = ['../AnswerKeys/anskey_',yearseason,'_quiz',quiznumber,'.txt']
%	fileID = fopen(answerkeyname,'w');
%	fprintf(fileID,'%8s %6s\n','Question','Answer');
%	fprintf(fileID,'%1i %1i\n',[1:numquestions;answerkey]);
%	fclose(fileID);
%	
%else
%	%open selected answer key and read in answers
%	answerkeyname = ['../AnswerKeys/',answerkeyname]
%	fileID = fopen(answerkeyname);
%	filedata_anskey = textscan(fileID, '%f%f', 'HeaderLines', 1, 'CollectOutput', 0);
%	fclose(fileID);
%	answerkey = filedata_anskey{2};
%end
%%%






%%%%
%%%%%%prior to running this code, in terminal call ghostscript to convert the scanned pdf into individual image files
%%%%%%gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=jpeg -r500 -sOutputFile=Batch1_%03d.jpg Batch1.pdf
%%%%%%gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=jpeg -r500 -sOutputFile=Batch2_%03d.jpg Batch2.pdf
%%%%%%gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=jpeg -r500 -sOutputFile=Batch3_%03d.jpg Batch3.pdf
%%%%
%
%%%%
%%%%%%FILL IN ANSWER KEY FOR QUIZ
%%answerkey for quiz 1 spring 2017
%%numoptions = 5;
%%answerkey(1) = 1;
%%answerkey(2) = 2;
%%answerkey(3) = 5;
%%answerkey(4) = 1;
%%answerkey(5) = 3;
%%answerkey(6) = 1;
%%answerkey(7) = 2;
%%answerkey(8) = 2;
%%answerkey(9) = 4;
%%answerkey(10) = 3;
%%%%
%
%%%%
%%%%%%prior to running this code, in terminal call ghostscript to convert the scanned pdf into individual image files
%%%%%%gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=jpeg -r500 -sOutputFile=Batch1_%03d.jpg Batch1.pdf
%%%%%%gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=jpeg -r500 -sOutputFile=Batch2_%03d.jpg test.pdf
%%%%%%gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=jpeg -r500 -sOutputFile=Batch3_%03d.jpg Batch3.pdf
%%%%
%
%%%%
%	%read in template movement from calibration file for answers
%	%dimmovetot(1,1,1) = templatedimmovetot(1,1,1);
%	%dimmovetot(2,1,1) = templatedimmovetot(2,1,1);
%	%distanceperp(1,1) = 0.9*templatedistanceperp(1,1);
%	%distanceslant(1,1) = 0.9*templatedistanceslant(1,1);
%    %
%	%%read in template movement from calibration file for student ID
%	%dimmoveIDtot(1,1,1) = templateIDdimmovetot(1,1,1);
%	%dimmoveIDtot(2,1,1) = templateIDdimmovetot(2,1,1);
%	%distanceIDperp(1,1) = 0.9*templateIDdistanceperp(1,1);
%	%distanceIDslant(1,1) = 0.9*templateIDdistanceslant(1,1);
%%%%
%
%
%
%%%%
%%test where the initial location is on the RGB image
%for k=1:10
%	for ii=1:5
%		for i=1:50
%			for j=1:50
%				scannedimageRGB(dim1initial-26+i,round(dim2initial)-26+j,1) = 240;
%				scannedimageRGB(dim1initial-26+i,round(dim2initial)-26+j,2)= 0;
%				scannedimageRGB(dim1initial-26+i,round(dim2initial)-26+j,3) = 0;
%			end
%		end
%	end
%end
%
%
%%%%
%
%%%%
%%test where the initial location is on the RGB image
%for k=1:10
%	for ii=1:5
%		for i=1:50
%			for j=1:50
%				scannedimageRGB(dim1teal-26+i,round(dim2teal)-26+j,1) = 240;
%				scannedimageRGB(dim1teal-26+i,round(dim2teal)-26+j,2)= 0;
%				scannedimageRGB(dim1teal-26+i,round(dim2teal)-26+j,3) = 0;
%			end
%		end
%	end
%end
%
%%%%
%
%
%
%%%%
%%test where the answer locations end up on the RGB image
%for k=1:10
%	for ii=1:5
%		for i=1:50
%			for j=1:50
%				scannedimageRGB(ansloc(1,k,ii)-26+i,ansloc(2,k,ii)-26+j,1) = 240;
%				scannedimageRGB(ansloc(1,k,ii)-26+i,ansloc(2,k,ii)-26+j,2)= 0;
%				scannedimageRGB(ansloc(1,k,ii)-26+i,ansloc(2,k,ii)-26+j,3) = 0;
%			end
%		end
%	end
%end
%
%
%
%%test where the ID locations end up on the RGB image
%for k=1:10
%	for ii=1:10
%		for i=1:50
%			for j=1:50
%				scannedimageRGB(IDloc(1,k,ii)-26+i,IDloc(2,k,ii)-26+j,1) = 240;
%				scannedimageRGB(IDloc(1,k,ii)-26+i,IDloc(2,k,ii)-26+j,2)= 0;
%				scannedimageRGB(IDloc(1,k,ii)-26+i,IDloc(2,k,ii)-26+j,3) = 0;
%			end
%		end
%	end
%end
%iptsetpref('ImshowAxesVisible','on');
%figure
%imshow(scannedimageRGB)
%%%%
%
%
%
%%%%
%%test where the answer locations end up on the RGB image
%for i=1:50
%	i
%	for j=1:50
%		scannedimageRGB(ansloc(1,1)-25+i,ansloc(2,1)-25+j,1) = 240;
%		scannedimageRGB(ansloc(1,1)-25+i,ansloc(2,1)-25+j,2)= 0;
%		scannedimageRGB(ansloc(1,1)-25+i,ansloc(2,1)-25+j,3) = 0;
%	end
%end
%iptsetpref('ImshowAxesVisible','on');
%figure
%imshow(scannedimageRGB)
%
%
%
%%show the slantfit on the RGB image as a test
%for i=1:size(scannedimageRGB,1)
%	scannedimageRGB(i,round(slantfit(2).*xpixels(i)+slantfit(1)),1) = 240;
%	scannedimageRGB(i,round(slantfit(2).*xpixels(i)+slantfit(1)),2) = 0  ;
%	scannedimageRGB(i,round(slantfit(2).*xpixels(i)+slantfit(1)),3) = 0  ;
%end
%iptsetpref('ImshowAxesVisible','on');
%figure
%imshow(scannedimageRGB)
%%%%
%
%
%%%%
%%place axes on the figure for imshow
%iptsetpref('ImshowAxesVisible','on');
%
%%plot the gray image
%figure
%imshow(scannedimagegray)
%
%%plot the RGB image
%figure
%imshow(scannedimageRGB)
%
%%plot various other things
%figure
%imshow(findbar)
%
%
%%compare student answers to answer key
%for i=1:length(answerkey)
%	answerkey(i)
%end
%
%
%for i=1:size(scannedimageRGB,1)
%	for j=1:size(scannedimageRGB,2)
%		if(abs(scannedimageRGB(i,j,1)-0)<65)
%			if(abs(scannedimageRGB(i,j,2)-0)<65)
%				if(abs(scannedimageRGB(i,j,3)-0)<65)
%					scannedimageRGB(i,j,1) = 200;
%					scannedimageRGB(i,j,2) = 0;
%					scannedimageRGB(i,j,3) = 0;
%				end
%			end
%		end
%	end
%end
%%%%
%
%%%%
%	%concept equations for finding the offset to a point
%	%dimmovetot(1,1) == x1 + x2
%	%dimmovetot(2,1) == slantfit(2) * x1 + perpfit(2) * x2
%	%dimmovetot(2,1) == slantfit(2) * (dimmovetot(1,1) - x2) + perpfit(2) * x2
%	%dimmovetot(2,1) - slantfit(2) * dimmovetot(1,1) == -1 * slantfit(2) * x2 + perpfit(2) * x2
%%%%
%
%
%
%
%
%%%%
%	findbar = zeros(size(scannedimagegray,1),round(size(scannedimagegray,2)/15)-5);
%	for j=1:round(size(scannedimagegray,2)/15)-5
%		%findbar(i,j) = mean(scannedimagegray(i,j:j+5));
%		%if(mod(i,50)==0)
%		%	i
%		%end
%	end
%%%%
%
%
%
%
%
%
%
%
%
%
%%%%
%%find the slant of the image using the black markers in each row
%[row col] = ind2sub(size(findbar),find(findbar<50));
%startrow = min(row);
%startcol = max(col(find(row == min(row))));
%
%%find startrow and col on image
%for i=1:10
%	for j=1:10
%		scannedimageRGB(startrow-5+i,startcol-5+j,1) = 255;
%	end
%end
%%%%
%
%%%%
%image(scannedimageRGB);
%axis image;
%%%%
%
%
%
%
%
%
%
%
