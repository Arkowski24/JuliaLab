import Base.*
import Base.^
import Base.convert
import Base.promote_rule

struct Gn{N}
    x
    function Gn{N}(num) where N
        tmp = mod(num, N)
        if (gcd(tmp, N) == 1)
            new{N}(tmp)
        else
            DomainError
        end
    end
end

*(a::Gn{N}, b::Gn{N}) where N = Gn{N}(a.x * b.x)
*(a::Integer, b::Gn{N}) where N = Gn{N}(a * b.x)
*(a::Gn{N}, b::Integer) where N = Gn{N}(a.x * b)

convert(::Type{Gn{N}}, x::Int64) where N = Gn{N}(x)
convert(::Type{Int64}, x::Gn{N}) where N = x.x

promote_rule(::Type{Gn{N}}, ::Type{Int64}) where N = Int64
promote_rule(::Type{Int64}, ::Type{Gn{N}}) where N = Int64

^(a::Gn{N}, x::Integer) where N =
    if (x == 0)
        Gn{N}(1)
    elseif (x % 2 == 0)
        tmp = a ^ div(x, 2)
        tmp * tmp
    else
        a * a ^ (x - 1)
    end

function period(a::Gn{N}) where N
    elemInGroup = elements_in_group(Gn{N})
    for i = 1:elemInGroup
        if (elemInGroup % i == 0)
            if (a^i == Gn{N}(1))
                return i
            end
        end
    end
    DomainError
end

function elements_in_group(::Type{Gn{N}}) where N
    elementsCount = 0
    for i = 1:(N - 1)
        if (gcd(i, N) == 1)
            elementsCount += 1
        end
    end
    elementsCount
end


function inverse(a::Gn{N}) where N
    t = 0
    r = N
    newt = 1
    newr = a.x
    while (newr != 0)
        quotient = div(r, newr)
        (t, newt) = (newt, t - quotient * newt)
        (r, newr) = (newr, r - quotient * newr)
    end

    if (r > 1)
        DomainError
    elseif (t < 0)
        return t + N
    else
        return t
    end
end

function decipher_message(publicKey::Gn{N}, msg) where N
    r = period(Gn{N}(msg))
    d = inverse(Gn{r}(publicKey.x))
    Gn{N}(msg) ^ d
end

function cipher_message(privateKey::Gn{N}, msg) where N
    Gn{N}(msg) ^ privateKey.x
end
