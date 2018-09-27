function [ ERPtrialsTot ] = procEventsST18_GH(blocks, mode, SaveFolder, gammaflag, ampflag)
% written by Tamar Regev, lab of prof. Leon Deouell, HUJI

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
    baselinewin=1:(1-win(1));
    baseline = ERPtrialsTot(:,baselinewin,:);
    memutsa=mean(baseline,2);
    memutsa_expanded = repmat(memutsa,[1 600 1]);
    fixed=ERPtrialsTot-memutsa_expanded;
    ERPtrialsTot=fixed;
    clear fixed
end

