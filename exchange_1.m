function count = change() 
    won = input('환전할 금액을 입력하세요 : ');
    
    %%%환율 입력%%%
    rate = [1235, 1333, 9.75, 193.87];
    exchange = zeros(1,4);
    count = zeros(1,4);
    tmp_money = [];
    
    for i=1:4
        exchange(i) = fix(won/rate(i));
    end
    
    %%%지폐 종류 입력%%%
    us = [100, 50, 20, 10, 5, 2, 1];
    euro = [500, 200, 100, 50, 20, 10, 5];
    japan = [10000, 5000, 2000, 1000];
    china = [50, 20, 10, 5, 1];
    
    for j=1:4
        switch j
            case 1
                tmp_money = us;
            case 2
                tmp_money = euro;
            case 3
                tmp_money = japan;
            case 4
                tmp_money = china;
        end

        for k=1:length(tmp_money)
            count(j) = count(j) + fix(exchange(j)/tmp_money(k));
            exchange(j) = rem(exchange(j),tmp_money(k));
        end
    end
    
    fprintf('지폐 수 : USD - %d개, Euro - %d개, ¥ - %d개, 元 - %d개',count(1), count(2), count(3), count(4));
end