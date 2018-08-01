import Base.randn

function aloc1()
    rng = MersenneTwister(1234);
    for i = 1:10
        randn(rng, Float64, (10, 10))
    end
end

function aloc2()
    rng = MersenneTwister(1234);
    for i = 1:100
        randn(rng, Float64, (10, 10))
    end
end

function tester(iterations)
    for i = 1:iterations
        aloc1()
        aloc2()
    end
end

function test1()
    tester(1)
    Profile.clear()
    @profile tester(5000)
    Profile.print()
end

using ProfileView
function test2()
    test1()
    ProfileView.view()
end

function test3(delT)
    Profile.init(n = 10^6, delay=delT)
    tester(1)
    Profile.clear()
    @profile tester(50000)
    Profile.print(format=:flat)
    #Profile.init(n = 10^6, delay = 0.001)
end
