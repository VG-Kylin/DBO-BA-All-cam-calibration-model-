function d = dfdaz(F, X, Y, Z, az, el, ro, tx, ty, tz)

d = [-F*((-cos(ro)*sin(az)+sin(ro)*sin(el)*cos(az))*(X-tx)+(cos(ro)*cos(az)+sin(ro)*sin(el)*sin(az))*(Y-ty))/(cos(el)*sin(az)*(X-tx)-cos(el)*cos(az)*(Y-ty)-sin(el)*(Z-tz))+F*((cos(ro)*cos(az)+sin(ro)*sin(el)*sin(az))*(X-tx)+(cos(ro)*sin(az)-sin(ro)*sin(el)*cos(az))*(Y-ty)+sin(ro)*cos(el)*(Z-tz))/(cos(el)*sin(az)*(X-tx)-cos(el)*cos(az)*(Y-ty)-sin(el)*(Z-tz))^2*(cos(el)*cos(az)*(X-tx)+cos(el)*sin(az)*(Y-ty))
 -F*((sin(ro)*sin(az)+cos(ro)*sin(el)*cos(az))*(X-tx)+(-sin(ro)*cos(az)+cos(ro)*sin(el)*sin(az))*(Y-ty))/(cos(el)*sin(az)*(X-tx)-cos(el)*cos(az)*(Y-ty)-sin(el)*(Z-tz))+F*((-sin(ro)*cos(az)+cos(ro)*sin(el)*sin(az))*(X-tx)+(-sin(ro)*sin(az)-cos(ro)*sin(el)*cos(az))*(Y-ty)+cos(ro)*cos(el)*(Z-tz))/(cos(el)*sin(az)*(X-tx)-cos(el)*cos(az)*(Y-ty)-sin(el)*(Z-tz))^2*(cos(el)*cos(az)*(X-tx)+cos(el)*sin(az)*(Y-ty))];
