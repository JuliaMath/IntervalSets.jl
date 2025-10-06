module IntervalSetsPrintfExt

using Printf
using IntervalSets
using IntervalSets: _show_suffix

INTERVAL_SEPARATOR = " .. "

Printf.plength(f::Printf.Spec{<:Printf.Ints}, x::Interval) =
    Printf.plength(f, leftendpoint(x)) + Printf.plength(f, rightendpoint(x)) +
    ncodeunits(INTERVAL_SEPARATOR) + ncodeunits(_show_suffix(x))

# separate methods for disambiguation
Printf.fmt(buf, pos, arg::Interval, spec::Printf.Spec{<:Printf.Floats}) = _fmt(buf, pos, arg, spec)
Printf.fmt(buf, pos, arg::Interval, spec::Printf.Spec{<:Printf.Ints}) = _fmt(buf, pos, arg, spec)

function _fmt(buf, pos, arg, spec)
    pos = Printf.fmt(buf, pos, leftendpoint(arg), spec)
    buf[pos:pos+ncodeunits(INTERVAL_SEPARATOR)-1] .= codeunits(INTERVAL_SEPARATOR)
    pos += ncodeunits(INTERVAL_SEPARATOR)
    pos = Printf.fmt(buf, pos, rightendpoint(arg), spec)

    suf = _show_suffix(arg)
    buf[pos:pos+ncodeunits(suf)-1] .= codeunits(suf)
    pos += ncodeunits(suf)

    return pos
end

end