Won = input("원화입력: ");
Euro = Won/1333;
E_500 = fix(Dol/500);
E__500 = mod(Dol,500);

E_200 = fix(E__500/200);
E__200 = mod(E__500,200);

E_100 = fix(E__200/100);
E__100 = mod(E__200,100);

E_50 = fix(E__100/50);
E__50 = mod(E__100,50);

E_20 = fix(E__50/20);
E__20 = mod(E__50,20);

E_10 = fix(E__20/10);
E__10 = mod(E__20,10);

E_5 = fix(E__10/5);

page = E_500 + E_200 + E_100 + E_50 + E_20 + E_10 + E_5;

fprintf('지폐의 개수 : %d', page)