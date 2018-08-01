#1
function print123(times)
    @sync begin
        lastNum = 2
        cycleTimes = 0

        for i in 2:-1:0
            @async begin
                while cycleTimes < times
                    if (lastNum + 1) % 3 == i
                        print(i + 1, " ")
                        if i == 2
                            cycleTimes += 1
                        end
                        lastNum = i
                    end
                    yield()
                end
            end
        end
    end
end

#2
import Base.Filesystem

function insFile(c ::Channel, root, files, ext)
    for file in files
        (fname, fext) = splitext(file)
        if fext == ext
            put!(c, joinpath(root, file))
        elseif ext == ""
            put!(c, joinpath(root, file))
        end
        yield()
    end
end

function producer(c ::Channel, dir, ext)
    println("Producer start")
    for (root, dirs, files) in walkdir(dir)
        insFile(c, root, files, ext)
    end
    close(c)
    println("Producer end")
end

function consumer(c ::Channel, s ::Channel)
    println("Consumer start")
    for cFile in c
        f = open(cFile)
        lCount = countlines(f)
        println("File: ", relpath(cFile), " - Lines count:", lCount)
        close(f)

        sumL = take!(s) + lCount
        put!(s, sumL)
        yield()
    end
    println("Consumer end")
end

function pcWalkDir(dir, ext ="", conCount=2)
    s = Channel(1)
    @sync begin
        c = Channel(32)
        put!(s, 0)
        @async producer(c, dir, ext)
        for i in 1:conCount
            @async consumer(c, s)
        end
    end
    sumL = take!(s)
    close(s)
    println(sumL)
end
