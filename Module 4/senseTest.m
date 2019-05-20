q = [0 0 0];

landmarks = [
    30 2 0.1;
    45 1 0.1;
    27 0.1 0.1;
    57 1.7 1.9;
    39 0.4 1.9;
];

[z, map, ids] = sense(q, Pb, landmarks) 