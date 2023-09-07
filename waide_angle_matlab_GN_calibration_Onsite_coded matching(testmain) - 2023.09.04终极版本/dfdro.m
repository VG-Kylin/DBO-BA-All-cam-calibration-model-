function d = dfdro(F, X, Y, Z, az, el, ro, tx, ty, tz)

d = [ -F*((-sin(ro)*cos(az)+cos(ro)*sin(el)*sin(az))*(X-tx)+(-sin(ro)*sin(az)-cos(ro)*sin(el)*cos(az))*(Y-ty)+cos(ro)*cos(el)*(Z-tz))/(cos(el)*sin(az)*(X-tx)-cos(el)*cos(az)*(Y-ty)-sin(el)*(Z-tz))
 -F*((-cos(ro)*cos(az)-sin(ro)*sin(el)*sin(az))*(X-tx)+(-cos(ro)*sin(az)+sin(ro)*sin(el)*cos(az))*(Y-ty)-sin(ro)*cos(el)*(Z-tz))/(cos(el)*sin(az)*(X-tx)-cos(el)*cos(az)*(Y-ty)-sin(el)*(Z-tz))];