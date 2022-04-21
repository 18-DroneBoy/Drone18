Won = input("원화입력: ");
Dol = Won/1235;
D_100 = fix(Dol/100);
D__100 = mod(Dol,100);

D_50 = fix(D__100/50);
D__50 = mod(D__100, 50);

D_20 = fix(D__50/20);
D__20 = mod(D__50,20);

D_10 = fix(D__20/10);
D__10 = mod(D__20,10);

D_5 = fix(D__10/5);
D__5 = mod(D__10,5);

D_2 = fix(D__5/2);
D__2 = mod(D__5,2);

D_1 = fix(D__2/1);

page = D_100 + D_50 + D_20 + D_10 + D_5 + D_2 + D_1;

fprintf('지폐의 개수 : %d', page)
