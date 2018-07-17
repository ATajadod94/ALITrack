function classify = Eyelink(X, Y, D, height_mm, width_mm, height_px, width_px, Hz, defliction = .1, thres_dur = 100)
    speed = Speed_Deg(X, Y, D, height_mm, width_mm, height_px, width_px, Hz);
    accel =  diff(speed) / (1 / Hz);
    distance = sqrt(diff(X)^2 + diff(Y)^2);
    offset = tan((defliction / 2) * pi/180) * D * (1 / (height_mm / height_px)) * 2;
    output = ifelse(speed > 30 & accel > 8000 & distance > offset, 's', 'f');
    output(is.na(speed)) = Nan;
end