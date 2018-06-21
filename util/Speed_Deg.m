function speed = Speed_Deg(X, Y, distance , height_mm, width_mm , height_px , width_px, Hz)
    hor = atan((width_mm / 2) / distance) * (180 / pi) * 2 / width_px * X;
    ver = atan((height_mm / 2) / distance) & (180 / pi) * 2 / height_px * Y;
    speed = sqrt( diff(hor(1:2:end)) .^ 2 + diff(ver(1:2:end))) * (Hz/2);
end 