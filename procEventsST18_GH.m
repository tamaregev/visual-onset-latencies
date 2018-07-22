function [ ERPtrialsTot ] = procEventsST18_GH(blocks, mode, SaveFolder, gammaflag, ampflag)
% written by Tamar Regev, lab of prof. Leon Deouell, HUJI

% 18/11/2014 - adapted from L:\Experiments\durationGamma\ECOG\Original Exp\Results\ST18\VisualStream\fastPreProc\ST18_procEvents.m  
% for use in - MasterScript_VOLST18
% 14/12/2014 - Tamar: added gammaflag just for sending to
% procEventsST18_block, where the actual calculation is done.
%%
    win=-299:300;
    ntrials_block = cell(length(blocks));
    ntrials = [];
    for b = 1:length(blocks)
        tic
        block = blocks{b};
        [ ERPtrials, info ] = procEventsST18_block_GH(block, mode, SaveFolder, win, gammaflag, ampflag);
        eval(['ERPtrials' block '=ERPtrials;']) 
        clear ERPtrials
        ntrials_block{b} = eval(['size(ERPtrials' block ',3);']);
        ntrials = ntrials + ntrials_block{b};
    end
    
    currtrial = [];
    untiltrial = [];
    for b = 1:length(blocks)
        block = blocks{b};
        if b==1
            currtrial = 1;
            untiltrial = ntrials_block{b};
        else
            currtrial = currtrial + ntrials_block{b-1};
            untiltrial = untiltrial + ntrials_block{b};
        end
        ERPtrialsTot(:,:,currtrial:untiltrial)= eval(['ERPtrials' block]);
        clear(['ERPtrials' block])
    end
    %% baseline subtract from ERPtrialsTot
    %this is the old matrix containing no targets and metadata
    baselinewin=1:(1-win(1));
    baseline = ERPtrialsTot(:,baselinewin,:);
    memutsa=mean(baseline,2);
    memutsa_expanded = repmat(memutsa,[1 600 1]);
    fixed=ERPtrialsTot-memutsa_expanded;
    ERPtrialsTot=fixed;
    clear fixed
end

