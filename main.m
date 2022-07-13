clc; clear;
detection = false;
%% 변수 선언
count = 0;

%HSV 값 설정
blu_h_min = 0.55; blu_h_max = 0.7; blu_s_min = 0.5; blu_s_max = 0.9;
red_h_min1 = 0; red_h_max1 = 0.05; red_h_min2 = 0.95; red_h_max2 = 1; red_s_min = 0.8; red_s_max = 1;
gre_h_min = 0.34; gre_h_max = 0.45; gre_s_min = 0.4; gre_s_max = 1;
pur_h_min = 0.7; pur_h_max = 0.85; pur_s_min = 0.5; pur_s_max = 1;

%% 객체 선언  
drone = ryze(); %드론 객체 선언
cam = camera(drone); %카메라 객체 선언

%% Main 함수
takeoff(drone);

for mission = 2:3
    if mission == 1
        disp('미션 1 수행중');
    
    elseif mission == 2
        disp('미션 2 수행중');
        
    elseif mission == 3
        disp('미션 3 수행중');  
    end
 
    %% BLUE SCREEN 확인 함수(Blue Screen Detection)
    while 1
        %이미지 처리(RGB->HSV)
        frame = snapshot(cam);
        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        
        blue_screen = (blu_h_min<h)&(h<blu_h_max)&(blu_s_min<s)&(s<blu_s_max); %파랑색 검출
        circle = imfill(blue_screen,'holes'); %빈 공간 채우기
         
        for x=1:size(blue_screen,1)
            for y=1:size(blue_screen,2)
                if blue_screen(x,y)==circle(x,y)
                    circle(x,y)=0;  %동일한 부분을 0으로 처리함으로써 원만 추출
                end
            end
        end
       
        %Hole 식별 시
        if sum(circle,'all') > 10000
            disp('hole 탐색 완료!');
            count = 0;
            break;

        %Hole 미식별 시
        else
            %화면의 좌우, 상하를 비교(imcrop함수를 이용하여 특정 영역 추출)
            diff_lr = sum(imcrop(blue_screen,[0 0 480 720]),'all') - sum(imcrop(blue_screen,[480 0 480 720]),'all');
            diff_ud = sum(imcrop(blue_screen,[0 0 960 360]),'all') - sum(imcrop(blue_screen,[0 360 960 360]),'all');
            
            if count == 7
                moveforward(drone, 'distance', 0.4, 'speed', 0.5);
                disp('Circle Detection : 기동 횟수 초과에 따른 직진 및 초기화');
                count = 0;
            
            else
                %미션 3에서 원 탐색을 위하여 3도씩 회전하면서 탐색 시행
                if mission == 3
                    turn(drone, deg2rad(3));
                    disp('3도 회전');
                    count = count + 1;
                end
                    
                %화면에 표시된 blue_screen의 좌우값 차이를 이용
                if diff_lr > 30000
                    moveleft(drone,'distance',0.25,'speed',0.5);
                    disp('왼쪽으로 0.25m 만큼 이동');
                    count = count + 1;

                elseif diff_lr < -30000
                    moveright(drone,'distance',0.25,'speed',0.5);
                    disp('오른쪽으로 0.25m 만큼 이동');
                    count = count + 1;
                end

                %화면에 표시된 blue_screen의 상하값 차이를 이용
                if diff_ud > 12000
                    moveup(drone,'distance',0.2,'speed',0.5);
                    disp('위쪽으로 0.2m 만큼 이동');
                    count = count + 1;

                elseif diff_ud < -12000
                    movedown(drone,'distance',0.2,'speed',0.5);
                    disp('아래쪽으로 0.2m 만큼 이동');
                    count = count + 1;
                end
            end
        end
    end
    
    %% 원 통과 함수(Circle Detection)
    while 1
        %이미지 처리(RGB->HSV)
        frame = snapshot(cam);
        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        
        blue_screen = (blu_h_min<h)&(h<blu_h_max)&(blu_s_min<s)&(s<blu_s_max); %파랑색 검출
        fill_screen = imfill(blue_screen,'holes'); %빈공간 채우기
        circle = fill_screen;
        
        for x=1:size(blue_screen,1)
            for y=1:size(blue_screen,2)
                if blue_screen(x,y)==circle(x,y)
                    circle(x,y)=0;  %동일한 부분을 0으로 처리함으로써 원만 추출
                end
            end
        end
        
        circle_detect_area = regionprops(circle,'Centroid','Area');
        circle_area = 0;

        for j = 1:length(circle_detect_area)
                if circle_area <= circle_detect_area(j).Area %가장 큰 영역 추출을 위하여 Area를 이용한 처리
                    circle_area = circle_detect_area(j).Area;
                    circle_center = circle_detect_area(j).Centroid; %가장 큰 영역의 중앙 좌표값 측정
                end
        end
        
        if circle_area >= 70000 && mission ~= 3
            disp('Circle Detection : 표식 탐색으로 진행');
            break;
        end
        
        if mission == 3
            red = (red_h_min<h) & (h<red_h_max) & (red_s_min<s) & (s<=red_s_max);
            red_detect_area = regionprops(red, 'Centroid', 'Area');
            red_area = 0;
            for j = 1:length(red_detect_area)
                if red_area <= red_detect_area(j).Area %가장 큰 영역 추출을 위하여 Area를 이용한 처리
                    red_area = red_detect_area(j).Area;
                    red_center = red_detect_area(j).Centroid;
                end
            end
            
            if red_area ~= 0 && circle_area >= 70000
                disp('Circle Detection : 표식 탐색으로 진행');
                break;
            end
        end
          
        if circle_area ~= 0
            if (420 <= round(circle_center(1)) && 540 >= round(circle_center(1))) && (160 <= round(circle_center(2)) && 300 >= round(circle_center(2)))
                    
                if circle_area >= 50000
                    disp('Circle Detection : 충분한 크기의 원 탐색 완료');
                    break;
                    
                else
                    moveforward(drone, 'Distance', 0.7, 'speed', 1);
                    disp('Circle Detection : 원으로 접근 중');
                end

            elseif 420 > round(circle_center(1))
                moveleft(drone, 'Distance', 0.2, 'speed', 0.5);
                disp('Circle Detection : 자세 제어를 위해 좌측으로 이동');

            elseif 540 < round(circle_center(1))
                moveright(drone, 'Distance', 0.2, 'speed', 0.5);
                disp('Circle Detection : 자세 제어를 위해 우측으로 이동');

            elseif 160 > round(circle_center(2))
                moveup(drone, 'Distance', 0.2, 'speed', 0.5);
                disp('Circle Detection : 자세 제어를 위해 위로 이동');

            elseif 300 < round(circle_center(2))
                movedown(drone, 'Distance', 0.2, 'speed', 0.5);
                disp('Circle Detection : 자세 제어를 위해 아래로 이동');
            end
        end
    end
    
        
    
    %% 표식 찾기 함수
    while 1
        %이미지 처리(RGB->HSV)
        frame = snapshot(cam);
        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
 
        if mission == 1 %원 통과 후 점 찾기(red)
            green = (gre_h_min<h) & (h<gre_h_max) & (gre_s_min<s) & (s<=gre_s_max);
             
            if sum(green, 'all') ~= 0
                if sum(green, 'all') > 2000
                    disp('Marker Detection : 미션 1 표식 감지');
                    turn(drone, deg2rad(90));
                    moveforward(drone, 'distance', 1);
                    break;
                    
                elseif 50 < sum(green, 'all') && sum(green, 'all') < 1000
                    disp('Marker Detection : 미션 1 표식 까지 이동');
                    moveforward(drone, 'distance', 0.5);
                end
            end
            
        elseif mission == 2 %원 통과 후 점 찾기(green)
            purple = (pur_h_min<h) & (h<pur_h_max) & (pur_s_min<s) & (s<=pur_s_max);
            purple_detect_area = regionprops(purple, 'Centroid', 'Area');
            purple_area = 0;
            for j = 1:length(purple_detect_area)
                if purple_area <= purple_detect_area(j).Area %가장 큰 영역 추출을 위하여 Area를 이용한 처리
                    purple_area = purple_detect_area(j).Area;
                    purple_center = purple_detect_area(j).Centroid;
                end
            end
            if sum(purple, 'all') ~= 0
                detection = true;
                if sum(purple, 'all') > 2200
                    disp('Marker Detection : 미션 2 표식 감지');
                    turn(drone, deg2rad(90));
                    moveforward(drone, 'distance', 1, 'speed', 1);
                    turn(drone, deg2rad(30));
                    moveleft(drone, 'distance', 0.3, 'speed', 1);
                    moveback(drone, 'distance', 0.4, 'speed', 0.5);
                    break;
                    
                elseif 50 < sum(purple, 'all') && sum(purple, 'all') < 1200
                    if purple_center(1) < 280
                        moveleft(drone, 'distance', 0.22, 'speed', 0.5);
                        disp('Marker Detection : 좌측으로 이동');
                    elseif purple_center(1) > 680
                        moveright(drone, 'distance', 0.22, 'speed', 0.5);
                        disp('Marker Detection : 우측으로 이동');
                    elseif purple_center(2) > 360
                        movedown(drone, 'distance', 0.22, 'speed', 0.5);
                        disp('Marker Detection : 아래로 이동');
                        
                    elseif 280 <= purple_center(1) && purple_center(1) <= 680 && purple_center(2) <= 360
                        moveforward(drone, 'distance', 0.5, 'speed', 1);
                        disp('Marker Detection : 전진');
                    else
                        moveback(drone, 'distance', 0.22, 'speed', 1);
                        disp('Marker Detection : 후진');

                    end
                        
                elseif 1200 <= sum(purple, 'all') && sum(purple, 'all') <= 2200
                    moveforward(drone, 'distance', 0.5, 'speed', 1);  
                    disp('Marker Detection : 전진');
                    
                else
                    moveforward(drone, 'distance', 0.2, 'speed', 1);
                end
                
            elseif sum(purple, 'all') == 0 && detection == true
                moveback(drone, 'distance', 0.2, 'speed', 1);
                detection = false;
              
            end
            
        elseif mission == 3  %원 통과 후 점 찾기(purple)
            red = ((red_h_min1<h) & (h<red_h_max1) | (red_h_min2<h) & (h<red_h_max2)) & (red_s_min<s) & (s<=red_s_max);
            red_detect_area = regionprops(red, 'Centroid', 'Area');
            red_area = 0;
            for j = 1:length(red_detect_area)
                if red_area <= red_detect_area(j).Area %가장 큰 영역 추출을 위하여 Area를 이용한 처리
                    red_area = red_detect_area(j).Area;
                    red_center = red_detect_area(j).Centroid;
                end
            end
            if sum(red, 'all') ~= 0
                if sum(red, 'all') > 2200
                    disp('미션 3 표식 감지');
                    land(drone);
                    disp('미션 종료');
                    break;
                 
                elseif 50 < sum(red, 'all') && sum(red, 'all') < 1200
                    if red_center(1) < 280
                        moveleft(drone, 'distance', 0.22, 'speed', 0.5);
                        disp('Marker Detection : 좌측으로 이동');
                    elseif red_center(1) > 680
                        moveright(drone, 'distance', 0.22, 'speed', 0.5);
                        disp('Marker Detection : 우측으로 이동');
                    elseif red_center(2) > 360
                        movedown(drone, 'distance', 0.22, 'speed', 0.5);
                        disp('Marker Detection : 아래로 이동');
                    else
                        moveforward(drone, 'distance', 0.3, 'speed', 1);
                        disp('Marker Detection : 전진');

                    end
                        
                elseif 1200 <= sum(red, 'all') && sum(red, 'all') <= 2200
                    moveforward(drone, 'distance', 0.5, 'speed', 1);  
                    disp('Marker Detection : 전진');
                end
              
            end
        end
    end
end

            
       