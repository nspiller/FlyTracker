%% TRACKER INTERFACE
function tracker_interface()
    videos.dir_in = '';
    videos.dir_out = '';
    videos.filter = '*';  
    options = [];
    f_calib = '';
    
    % specify valid extensions
    videoReaderFmts = VideoReader.getFileFormats();
    commonFmts = {'avi','mov','mp4','wmv','m4v','mpg'};
    specialFmts = {'fmf','sbfmf','ufmf','seq','bin'};
    valid_extns = union(commonFmts,specialFmts);
    valid_extns = union({videoReaderFmts.Extension},valid_extns);  
    
    % ----- LOAD INTERFACE -----   
    % MAIN WINDOW
    scrsz = get(0,'ScreenSize');
    fig_width = 620;
    fig_height = 500;
    figure_name = sprintf('FlyTracker-%s', flytracker_version_string()) ;
    fig_h = figure('Position',[scrsz(3)/2-fig_width/2 scrsz(4)/2-fig_height/2 fig_width fig_height],...
        'Name',figure_name,'NumberTitle','off','Color',.94*[1 1 1]);
    set(fig_h,'MenuBar','none')
    set(fig_h,'Resize','off')
    set(fig_h,'CloseRequestFcn',@ui_close)
    figclr = get(fig_h,'color');
    fs = 72/get(0,'ScreenPixelsPerInch'); % scale fonts to resemble the mac
    
    % title
    text_x = 20;
    text_y = fig_height-50;
    uicontrol('Style', 'text', 'String', 'Select files:', ...
    'Position',[text_x text_y fig_width-40 30], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', figclr, ...
    'FontSize',fs*14, 'FontWeight', 'bold');
    
    % SELECT READ FOLDER
    text_y = text_y - 40;
    uicontrol('Style', 'pushbutton', 'String', 'VIDEO folder', ...
    'Position',[text_x text_y-3 160 35], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', figclr, ...
    'FontSize',fs*12, ...
    'Callback', @selectReadFolder, ...
    'ToolTipString','Specify folder containing videos to process');
    f_read_h = uicontrol('Style', 'edit', 'String', videos.dir_in, ...
    'Position',[text_x+170 text_y 300 30], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', figclr, ...
    'FontSize',fs*10);
    extn_h = uicontrol('Style', 'popup', 'String', 'extn', ...
    'Position',[text_x+490 text_y-2 80 30], ...
    'Value',1,'BackgroundColor',figclr,...
    'FontSize',fs*12, ...
    'Callback',@setExtension,...
    'ToolTipString','Only videos with selected extension will be processed');  
    
    % SELECT SAVE FOLDER
    text_y = text_y - 50;
    uicontrol('Style', 'pushbutton', 'String', 'OUTPUT folder', ...
    'Position',[text_x text_y-3 160 35], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', figclr, ...
    'FontSize',fs*12, ...
    'Callback', @selectSaveFolder, ...
    'ToolTipString','Specify folder to which output will be saved');
    f_save_h = uicontrol('Style', 'edit', 'String', videos.dir_out, ...
    'Position',[text_x+170 text_y 300 30], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', figclr, ...
    'FontSize',fs*10);   

    % CALIBRATION FILE
    text_y = text_y - 50;
    uicontrol('Style', 'pushbutton', 'String', 'calibration file', ...
    'Position',[text_x text_y-3 160 35], ...
    'HorizontalAlignment', 'center', ...
    'BackgroundColor', figclr, ...
    'FontSize',fs*12,...
    'Callback', @selectCalibrationFile, ...
    'ToolTipString','Select existing calibration file');     
    f_calib_h = uicontrol('Style', 'edit', 'String',  f_calib, ...
    'Position',[text_x+170 text_y 300 30], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', figclr, ...
    'FontSize',fs*10);
    uicontrol('Style', 'text', 'String', '/', ...
    'Position',[text_x+470 text_y-15 20 40], ...
    'HorizontalAlignment', 'center', ...
    'BackgroundColor', figclr, ...
    'FontSize',fs*12);     
    uicontrol('Style', 'pushbutton', 'String', 'CALIBRATE', ...
    'Position',[text_x+490 text_y-3 80 35], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', [.9 .85 .5], ...
    'FontSize',fs*10, ...
    'Callback', @runCalibrator, ...
    'ToolTipString','Create new calibration file');

    % title
    text_y = text_y - 30;
    uicontrol('Style', 'text', 'String', '', ...
    'Position',[text_x text_y fig_width-40 1], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', figclr*.8, ...
    'FontSize',fs*14, 'FontWeight', 'bold');
    text_y = text_y - 50;
    uicontrol('Style', 'text', 'String', 'Options:', ...
    'Position',[text_x text_y fig_width-40 30], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', figclr, ...
    'FontSize',fs*14, 'FontWeight', 'bold');

    % OPTIONS
    text_y = text_y - 40;
    % max minutes to track
    uicontrol('Style', 'text', 'String', 'Process:', ...
        'Position',[text_x text_y 60 25], ...
        'HorizontalAlignment', 'right', ...
        'BackgroundColor', figclr, ...
        'FontSize',fs*13);   
    text_x = text_x + 70;
    uicontrol('Style', 'text', 'String', 'max minutes:', ...
        'Position',[text_x text_y 87 25], ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', figclr, ...
        'FontSize',fs*12, ...
        'ToolTipString','Upper limit on number of minutes to process');        
    max_h = uicontrol('Style', 'edit', 'String', 'Inf', ...
        'Position',[text_x+87 text_y+2 50 25], ...
        'HorizontalAlignment', 'center', ...
        'BackgroundColor', figclr, ...
        'FontSize',fs*12);    
    % chunksize 
    chunktype_h = uicontrol('Style', 'popup', ...
        'String', 'chunksize (frames):|number of chunks:', ...
        'Position',[text_x+158 text_y 155 25], ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', figclr, ...
        'FontSize',fs*12,...
        'Callback',@setChunkType, ...
        'ToolTipString','Each video is processed in chunks of frames');    
    chunk_h = uicontrol('Style', 'edit', 'String', '10000', ...
        'Position',[text_x+311 text_y+2 54 25], ...
        'HorizontalAlignment', 'center', ...
        'BackgroundColor', figclr, ...
        'FontSize',fs*12);    
    % use parallel pool     
    n_cores = feature('numCores');
    if n_cores > 1
        popstring = 'use 1 core';
        for i=2:n_cores
            popstring = [popstring '|use ' num2str(i) ' cores']; %#ok<AGROW>
        end
        par_h = uicontrol('Style', 'popup', 'String',popstring, ...
            'Position',[text_x+390 text_y 120 25], ...
            'HorizontalAlignment', 'left', ...
            'BackgroundColor', figclr, ...
            'FontSize',fs*12, ...
            'Callback',@setNCores,...
            'ToolTipString','Process chunks in parallel on multiple cores');    
    end
    text_x = text_x - 70;
    % OUTPUT OPTIONS
    text_y = text_y - 45;
    uicontrol('Style', 'text', 'String', 'Extra:', ...
        'Position',[text_x text_y 60 25], ...
        'HorizontalAlignment', 'right', ...
        'BackgroundColor', figclr, ...
        'FontSize',fs*13);   
    % output writeJAABA folders
    jab_h = uicontrol('Style', 'checkbox', 'String', 'save JAABA folders', ...
        'Position',[text_x+70 text_y+2 200 30], ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', figclr, ...
        'FontSize',fs*12, ...
        'ToolTipString','Save output to JAABA compatible folders');    
    xls_h = uicontrol('Style', 'checkbox', 'String', 'save to .xls', ...
        'Position',[text_x+228 text_y+2 200 30], ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', figclr, ...
        'FontSize',fs*12, ...
        'ToolTipString','Save output to .xls');    
    seg_h = uicontrol('Style', 'checkbox', 'String', 'save segmentation', ...
        'Position',[text_x+340 text_y+2 200 30], ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', figclr, ...
        'FontSize',fs*12, ...
        'ToolTipString','Save video segmentation (this produces large files)');    

    % CLOSE and TRACK BUTTONS   
    text_y = text_y - 30;
    uicontrol('Style', 'text', 'String', '', ...
    'Position',[text_x text_y fig_width-40 1], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', figclr*.8, ...
    'FontSize',fs*14, 'FontWeight', 'bold');
    text_y = text_y - 70;
    text_x = text_x + 170;
    uicontrol('Style', 'pushbutton', 'String', 'CLOSE', ...
    'Position',[text_x text_y-5 80 40], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', [.9 .6 .7], ...
    'FontSize',fs*12, ...
    'Callback', @ui_close, ...
    'ToolTipString','Close without tracking');    
    uicontrol('Style', 'pushbutton', 'String', 'TRACK', ...
    'Position',[text_x+125 text_y-5 140 40], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', [.4 .8 .5], ...
    'FontSize',fs*12, ...
    'Callback', @finishAndTrack, ...
    'ToolTipString','Track all videos in READ folder');
    
    % CALLBACK FUNCTIONS
    function setChunkType(hObj,event) %#ok<INUSD>
        value = get(hObj,'Value');
        if value == 1
            set(chunk_h,'String',num2str(10000));
        else
            n_chunks = 10;
            if n_cores > 1
                n_chunks = get(par_h,'Value')*2;                
            end
            set(chunk_h,'String',num2str(n_chunks));
        end
    end
    function setNCores(hObj,event) %#ok<INUSD>
        options.num_cores = get(hObj,'Value');                
        if options.num_cores > 1
            set(chunk_h,'String',num2str(options.num_cores*2));
            set(chunktype_h,'Value',2);
        else
            set(chunk_h,'String',num2str(10000));
            set(chunktype_h,'Value',1);
        end
    end
    function setExtension(hObj,event) %#ok<INUSD>
        string = get(hObj,'String');        
        if ~iscell(string), 
            return; 
        end
        idx = get(hObj,'Value');
        val = string{idx};
        if isempty(val)
            val = '*';
        elseif ~strcmp(val(1),'*')
            val = ['*' val];
        end
        videos.filter = val;
    end
    function updateExtensions()
        directory = videos.dir_in;
        files = dir(fullfile(directory,'*'));
        extns = cell(1,numel(files));
        count_valid = 0;
        for f=1:numel(files)
            [~,~,extn] = fileparts(files(f).name);  
            if any(strcmpi(extn(2:end),valid_extns))
                count_valid = count_valid+1;
                extns{count_valid} = extn;
            end
        end
        extns = extns(1:count_valid);
        extns = unique(extns);        
        if numel(extns)>0
            set(extn_h,'string',extns);  
            videos.filter = ['*' extns{1}];
        end
    end
    function selectReadFolder(hObj,event) %#ok<INUSD>
        directory = uigetdir(videos.dir_out,'Select READ folder');
        if ~directory, directory = ''; end
        videos.dir_in = directory;
        set(f_read_h,'String',directory);
        % update extensions
        updateExtensions;        
        % update save directory
        videos.dir_out = directory;
        set(f_save_h,'String',directory);            
        % update calibration file
        f_calib = fullfile(videos.dir_in,'calibration.mat');
        if ~exist(f_calib,'file')
           f_calib = '';
        else 
           set(f_calib_h,'String',f_calib);
        end
    end 
    function selectSaveFolder(hObj,event) %#ok<INUSD>
        directory = uigetdir(videos.dir_in,'Select SAVE folder');
        if ~directory, directory = ''; end
        videos.dir_out = directory;
        set(f_save_h,'String',directory);
        if numel(get(f_read_h,'String')) == 0
            videos.dir_in = directory;
            set(f_read_h,'String',directory);
        end
    end
    function selectCalibrationFile(hObj,event) %#ok<INUSD>
        [file,path] = uigetfile('*.mat','Select calibration file',videos.dir_in);
        f_calib = fullfile(path,file);
        if ~f_calib, f_calib = ''; end
        set(f_calib_h,'String',f_calib);
    end
    function runCalibrator(hObj,event) %#ok<INUSD>
       vid_files = dir(fullfile(videos.dir_in, videos.filter));
       vid_files([vid_files.isdir]) = [];
       vid_files = { vid_files.name };           
       valid = false(size(vid_files));
       for f=1:numel(vid_files)
          [~,~,extn] = fileparts(vid_files{f});  
          if any(strcmpi(extn(2:end),valid_extns))
              valid(f) = 1;
          end
       end
       vid_files = vid_files(valid);
       if numel(vid_files) == 0
           customDialog('warn','No valid video folder selected',12*fs);
           return;
       end
       f_vid = fullfile(videos.dir_in, vid_files{1});
       f_calib = fullfile(videos.dir_in,'calibration.mat');
       calib_success = calibrator(f_vid,f_calib);
       if ~calib_success, f_calib = ''; end
       set(f_calib_h,'String',f_calib);
    end
    function finishAndTrack(hObj,event) %#ok<INUSD>
        % collect file information
        videos.dir_in = get(f_read_h,'String');
        videos.dir_out = get(f_save_h,'String');
        if isempty(videos.dir_in) || isempty(videos.dir_out) || ...
                isempty(videos.filter) || ~exist(f_calib,'file')
            customDialog('warn','File information incomplete',12*fs);
            return;
        end
        % collect options
        str = get(max_h,'String');
        minutes = str2double(str);
        if ~isempty(minutes)
            options.max_minutes = minutes;
        end        
        str = get(chunk_h,'String');
        value = str2double(str);
        type = get(chunktype_h,'Value');        
        if ~isempty(value)
            if type == 1
                options.granularity = value;
            else
                options.num_chunks = value;
            end    
        end
        value = get(jab_h,'Value');
        options.save_JAABA = value;
        value = get(xls_h,'Value');
        options.save_xls = value;
        value = get(seg_h,'Value');
        options.save_seg = value;
        % track
        delete(fig_h)
        pause(.5)
        run_tracker(videos,options,f_calib);
    end
    function ui_close(hObj,event) %#ok<INUSD>
        delete(fig_h);     
    end    
end
