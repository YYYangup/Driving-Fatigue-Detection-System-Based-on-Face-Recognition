function region = increasebbox(bbox, scale)


region(1) = floor(bbox(1) - (scale - 1)/2*bbox(3));
region(2) = floor(bbox(2) - (scale - 1)/2*bbox(4));

region(3) = floor(scale*bbox(3));
region(4) = floor(scale*bbox(4));

end