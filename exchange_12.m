Won = input("원화입력: ");
Euro = Won/1333;
Euro_500 = fix(Euro/500);
Euro__500 = mod(Euro,500);

Euro_200 = fix(Euro__500/200);
Euro__200 = mod(Euro__500,200);

Euro_100 = fix(Euro__200/100);
Euro__100 = mod(Euro__200,100);

Euro_50 = fix(Euro__100/50);
Euro__50 = mod(Euro__100,50);

Euro_20 = fix(Euro__50/20);
Euro__20 = mod(Euro__50,20);

Euro_10 = fix(Euro__20/10);
Euro__10 = mod(Euro__20,10);

Euro_5 = fix(Euro__10/5);

page_euro = Euro_500 + Euro_200 + Euro_100 + Euro_50 + Euro_20 + Euro_10 + Euro_5;

Dollor = Won/1235;
Dollor_100 = fix(Dollor/100);
Dollor__100 = mod(Dollor,100);

Dollor_50 = fix(Dollor__100/50);
Dollor__50 = mod(Dollor__100, 50);

Dollor_20 = fix(Dollor__50/20);
Dollor__20 = mod(Dollor__50,20);

Dollor_10 = fix(Dollor__20/10);
Dollor__10 = mod(Dollor__20,10);

Dollor_5 = fix(Dollor__10/5);
Dollor__5 = mod(Dollor__10,5);

Dollor_2 = fix(Dollor__5/2);
Dollor__2 = mod(Dollor__5,2);

Dollor_1 = fix(Dollor__2/1);

page_dollor = Dollor_100 + Dollor_50 + Dollor_20 + Dollor_10 + Dollor_5 + Dollor_2 + Dollor_1;

J_rate = 9.65;
japan_change = [0 0 0 0];

Japan = Won/J_rate;
japan_change(1) = fix(Japan/10000);
japan_change(2) = fix((rem(Japan,10000))/5000);
japan_change(3) = fix(rem(rem(Japan,10000),5000)/2000);
japan_change(4) = fix(rem(rem(rem(Japan,10000),5000),2000)/1000);
japan_money = japan_change(1) + japan_change(2) + japan_change(3) + japan_change(4);

fprintf('유로 지폐의 개수 : %d, 달러 지폐의 개수 %d', page_euro, page_dollor)