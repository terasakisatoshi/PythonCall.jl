# :PyFloat_FromDouble => (Cdouble,) => PyPtr,
# :PyFloat_AsDouble => (PyPtr,) => Cdouble,

"""
    pyfloat!(ans, x=0.0)

In-place `pyfloat(x)`.
"""
pyfloat!(ans::PyRef, x::Real=0.0) = setptr!(ans, errcheck(C.PyFloat_FromDouble(x)))
function pyfloat!(ans, x)
    x = pyargref!(ans, x)
    setptr!(ans, errcheck(C.PyNumber_Float(getptr(x))))
end

"""
    pyfloat(x=0.0)

Convert `x` to a Python `float`.
"""
pyfloat(x=0.0) = pyfloat!(pynew(), x)
export pyfloat

pyisfloat(x) = pytypecheck(x, pybuiltins.float)

pyfloat_asdouble(x) = errcheck_ambig(@autopy x C.PyFloat_AsDouble(getptr(x_)))

function pyconvert_rule_float(::Type{T}, x::Py) where {T<:Number}
    val = pyfloat_asdouble(x)
    if T in (Float16, Float32, Float64, BigFloat)
        pyconvert_return(T(val))
    else
        pyconvert_tryconvert(T, val)
    end
end

# NaN is sometimes used to represent missing data of other types
# so we allow converting it to Nothing or Missing
function pyconvert_rule_float(::Type{Nothing}, x::Py)
    val = pyfloat_asdouble(x)
    if isnan(val)
        pyconvert_return(nothing)
    else
        pyconvert_unconverted()
    end
end

function pyconvert_rule_float(::Type{Missing}, x::Py)
    val = pyfloat_asdouble(x)
    if isnan(val)
        pyconvert_return(missing)
    else
        pyconvert_unconverted()
    end
end
