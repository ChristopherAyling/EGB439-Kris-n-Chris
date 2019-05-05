Pb = PiBot('172.19.232.171', '172.19.232.11', 32);

img = Pb.getImage();
idisp(img)
 
identity = identifyBeaconId(img)