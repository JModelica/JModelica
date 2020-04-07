package TimeEvents

    model Basic1
        Real x;
    equation
        if time < 1 then
            der(x) = 1;
        else
            der(x) = -1;
        end if;
    end Basic1;

    model Basic2
        Real x;
        parameter Real p = 2;
    equation
        if time < p then
            der(x) = 1;
        else
            der(x) = -1;
        end if;
    end Basic2;

    model Basic3
        Real x;
        parameter Real p = 2;
        Boolean b = time < 1.5;
    equation
        if time < p or b then
            der(x) = 1;
        else
            der(x) = -1;
        end if;
    end Basic3;

    model Basic4
        Real x;
        parameter Real p = 2;
    initial equation
        x = if time > 0.5 then 1 else 2;
    equation
        der(x) = -1;
    end Basic4;

    model Basic5
        Real x(start=1.1);
    equation
        if (time < 0.5) then
            der(x) = -0.5*x;
        else
            der(x) = -1;
        end if;
    end Basic5;

    model Advanced1
        Real x(start = 1);
        Integer i(start=0);
    equation
        der(x) = -1;
        when {time >= 0.5,time>0.5} then
            i=pre(i)+1;
        end when;
    end Advanced1;

    model Advanced2
        Real x(start = 1);
        Integer i(start=0);
    equation
        der(x) = -1;
        when {time >= 0.5,0.5<time} then
            i=pre(i)+1;
        end when;
    end Advanced2;

    model Advanced3
        Real x(start = 1);
        Integer i(start=0);
        Integer j(start=0);
    equation
        der(x) = -1;
        when {time >= 0.5,0.5<time} then
            i=pre(i)+1;
        end when;
        when {0.5<time} then
            j=pre(j)+1;
        end when;
    end Advanced3;

    model Advanced4
        Real x(start = 1);
        Integer i(start=0);
        Integer j(start=0);
    equation
        der(x) = -1;
        when {time >= 0.5} then
            i=pre(i)+1;
        end when;
        when {0.5<time} then
            j=pre(j)+1;
        end when;
    end Advanced4;

    model Advanced5
        Real x(start=1.1);
    equation
        when (time>=0.5) then
            reinit(x, 5);
            end when;
        der(x) = -0.5*x;
    end Advanced5;

    model Mixed1
        Real x(start=0.5);
        parameter Real p = 2;
        Boolean b = time < 1.5;
    equation
        if time < p or b then
            der(x) = if x < 1 then 1 else 0.5;
        else
            der(x) = if x < 1 then -0.5 else -1;
        end if;
    end Mixed1;

    model TestSampling1
        parameter Real sampleInterval=0.1;
        Boolean y;
    equation
        y = sample(0, sampleInterval);
    end TestSampling1;

    model TestSampling2
        parameter Real sampleInterval=1e-10;
        Boolean y;
    equation
        y = sample(0, sampleInterval);
    end TestSampling2;

    model TestSampling3
        parameter Real sampleInterval=1e60;
        Boolean y;
    equation
        y = sample(0, sampleInterval);
    end TestSampling3;

    model TestSampling4
        parameter Real sampleOffest=1e-6;
        parameter Real sampleInterval=1e-10;
        Boolean y;
    equation
        y = sample(sampleOffest, sampleInterval);
    end TestSampling4;

    model TestSampling5
        parameter Real sampleOffest=1e-20;
        parameter Real sampleInterval=1e60;
        Boolean y;
    equation
        y = sample(sampleOffest, sampleInterval);
    end TestSampling5;

    model TestSampling6
        parameter Real sampleOffest=1e60;
        parameter Real sampleInterval=1e60;
        Boolean y;
    equation
        y = sample(sampleOffest, sampleInterval);
    end TestSampling6;

    model TestSampling7
        parameter Real sampleOffest=1e-20;
        parameter Real sampleInterval=1e1;
        Boolean y;
    equation
        y = sample(sampleOffest, sampleInterval);
    end TestSampling7;

    model TestSampling8
        parameter Real sampleOffest=1e1;
        parameter Real sampleInterval=1e-20;
        Boolean y;
    equation
        y = sample(sampleOffest, sampleInterval);
    end TestSampling8;

    model TestSampling9
        parameter Real sampleVal=0.1;
        Boolean y;
    equation
        y = sample(sampleVal, sampleVal);
    end TestSampling9;

    model StateEventAfterTimeEvent
        Real s;
        Boolean b;
        Boolean c;
    equation
        b = time > 0.1-1e-14;
        c = time >= 0.5;
        der(s) = if s < 0.1 then 1 else 3;
    end StateEventAfterTimeEvent;

end TimeEvents;
