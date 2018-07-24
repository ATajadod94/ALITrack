% This test program computes a few recurrence analyses

% Example 1:
% These are simply categories. They could, for example, be identifiers of grid elements
% on a fixation grid.

fixations=[37 28 28 28 19 18 9 1 1 9 9 1 1 9 9 17 34 42 43 44 44 45 36 28 19 11 1];

param.delay = 1;
param.embed = 1;
param.rescale = 0;
param.metric = 'euclidian';
param.adjacency=[];
param.linelength = 2;
param.radius=0.1;

result=Rqa(fixations,param);
PlotRecurrenceMatrix(result.recmat,'results/rqa1.png');

display(...
['nRec=' num2str(result.nrec) ' %Rec=' num2str(result.rec) ...
 ' Det=' num2str(result.det) ' MeanLine=' num2str(result.meanline) ...
 ' MaxLine=' num2str(result.maxline) ' ENT=' num2str(result.ent) ...
 ' RelENT=' num2str(result.relent) ' Trend=' num2str(result.trend) ...
 ' LAM=' num2str(result.lam) ' TT=' num2str(result.tt) ...
 ' corm=' num2str(result.corm)] )

pause 

% Example 2:
% The input consists of a series of fixations in (x,y) coordinates.

fixations = ...
[510.4  385.4;
 466.5  429.5;
 406.0  448.9;
 135.1  332.8;
 296.1  409.2;
 117.5  398.3;
 317.7  327.4;
 439.3  305.5;
 302.4  270.2;
 444.0  347.5;
 507.3  454.3;
 341.2  327.5;
 308.8  259.3;
 459.1  270.8;
 493.9  293.2;
 630.3  341.8;
 655.9  431.7;
 798.6  529.0;
 851.1  400.3;
 768.9  488.8;
 485.0  595.2;
 256.0  707.6;
 358.8  652.0;
 264.7  564.3;
  87.5  551.0;
  68.3  557.6;
 310.1  583.2;
 474.2  559.0;
 449.9  611.5;
 176.9  570.0;
 279.8  567.2;
 358.3  576.0;
 440.2  550.4;
 505.4  612.0;
 655.4  555.6;
 884.5  557.4;
 884.1  516.5;
 683.5  448.1;
 635.3  325.3;
 570.5  292.5];

param.delay = 1;
param.embed = 1;
param.rescale = 0;
param.metric = 'euclidian';
param.adjacency=[];
param.linelength = 2;
param.radius=64;

result=Rqa(fixations,param);
PlotRecurrenceMatrix(result.recmat,'results/rqa2.png');

display(...
['nRec=' num2str(result.nrec) ' %Rec=' num2str(result.rec) ...
 ' Det=' num2str(result.det) ' MeanLine=' num2str(result.meanline) ...
 ' MaxLine=' num2str(result.maxline) ' ENT=' num2str(result.ent) ...
 ' RelENT=' num2str(result.relent) ' Trend=' num2str(result.trend) ...
 ' LAM=' num2str(result.lam) ' TT=' num2str(result.tt) ...
 ' corm=' num2str(result.corm)] )
