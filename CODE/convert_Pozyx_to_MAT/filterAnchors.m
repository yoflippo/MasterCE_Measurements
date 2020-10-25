%% separate data per anchor id
function output = filterAnchors(dataPozyx)
anchorids = {'696C','6E49','6E02','695F',};

for ids = 1:length(anchorids)
    output(ids).name = anchorids{ids};
    output(ids).optitrack_id = ids;
   % create index vector with data with corresponding anchor id
   idxids = contains(dataPozyx{:,2},anchorids{ids});
   output(ids).idxraw = idxids;
   
   % select data
   output(ids).data = dataPozyx(idxids,:);
   
   output(ids).range = table2array(dataPozyx(idxids,6));
   output(ids).range(output(ids).range > 20000) = NaN;
   output(ids).range = array2table(round(fillgaps(output(ids).range)));
   
   output(ids).time = dataPozyx(idxids,3);
end
end

