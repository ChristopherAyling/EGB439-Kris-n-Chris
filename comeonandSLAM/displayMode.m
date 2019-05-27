function displayMode(mode_, Pb)
    switch mode_
        case "setup"
            Pb.setLEDArray(bin2dec('1000000000000000'))
        case "scan"
            Pb.setLEDArray(bin2dec('1100000000000000'))
        case "d2c"
            Pb.setLEDArray(bin2dec('11100000000000000'))
        case "complete"
            Pb.setLEDArray(bin2dec('1111111111111111'))
    end  
end