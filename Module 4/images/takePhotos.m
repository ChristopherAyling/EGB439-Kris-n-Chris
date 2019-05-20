% connect to bot
Pb = PiBot('172.19.232.171', '172.19.232.11', 32);

photo = Pb.getImage();

idisp(photo)

fname = dec2bin(randi(127));
save(fname, 'photo')
