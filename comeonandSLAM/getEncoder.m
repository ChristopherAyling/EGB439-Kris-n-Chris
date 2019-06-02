function encoder = getEncoder(Pb)
    encoder = Pb.getEncoder();
    while isempty(encoder)
       encoder = Pb.getEncoder(); 
    end
end

