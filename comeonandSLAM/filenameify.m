function filename = filenameify(fname)
    fname(regexp(fname,['[\\= ', char(176), ']']))=[];
    fname(regexp(fname,['[.]']))=['p'];
    filename = [fname '.png'];
end