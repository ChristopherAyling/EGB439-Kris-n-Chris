function blueLEDs(piBot, desiredState)
    %BLUELEDS set all Blue LEDs
    % turn all on `blueLEDs(1)`
    % turn all on `blueLEDs(0)`
    v = desiredState;
    if desiredState
        v = 65535;
    end
    piBot.setLEDArray(v)
end

