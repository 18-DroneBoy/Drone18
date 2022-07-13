2022 미니드론 경진대회 18-DroneBoy 팀
====
이 글은 [2022 미니드론 경진대회](http://mini-drone.co.kr/view_notice?post_id=16481977576163440691612387)에 참가한
18-DroneBoy 팀의 대회준비 과정을 기록한 결과물이다.

----
🎈 준비
====
코드설명에 들어가기 앞서 준비된 하드웨어적 요소들을 살펴보자.  
* 사용기체  
DJI Tello 미니드론을 이용하였다.

![tello](https://user-images.githubusercontent.com/102723228/178655561-3c8f5806-bc1b-486a-b8db-ebadbc10210b.png)
<img src="![tello](https://user-images.githubusercontent.com/102723228/178655561-3c8f5806-bc1b-486a-b8db-ebadbc10210b.png)">



* 환경구축  
작성된 코드를 적용해보기 위한 환경이 필요했다. [주어진 맵의 규격과 고려사항](http://mini-drone.co.kr/view_notice?post_id=16566445069343700497480829)을 토대로 최대한 대회환경과 유사하게 구성하였다.
장소는 학교 강의실을 빌렸고, 필요한 물품은 구매하여 세팅하였다.

![hong](https://user-images.githubusercontent.com/102723228/178643254-b4e66851-ecc6-4fc4-9793-32a0e628670b.jpg)
<img src="![hong](https://user-images.githubusercontent.com/102723228/178643466-71bf2aaf-c2a5-4618-a451-1859624eac76.jpg)">
![KakaoTalk_20220713_174139855_01](https://user-images.githubusercontent.com/102723228/178691157-db95d935-a87a-45d0-85ee-3e0597e30f8d.jpg)
<img src="![KakaoTalk_20220713_174139855_01](https://user-images.githubusercontent.com/102723228/178691157-db95d935-a87a-45d0-85ee-3e0597e30f8d.jpg)">


🎈 대회진행전략
====

2022 미니드론 경진대회에서 우리 팀의 전략은 빠른시간 내에 불규칙적인 장애물을 통과하는 것이 목적이다. 이를 위해 matlab에서 제공하는 image processing toolbox를 사용하여  rgb2hsv, imcrop, regionprops 함수 등으로 이미지 처리를 수행하였다. 

전체적인 과정으로 우선 takeoff 이후 카메라 전방에 있는 천막 내 x,y 직경을 측정하여 구멍을 만든다. 다음으로는 만들어낸 구멍을 이용하여 화면상 특정한 위치에 존재하도록 드론을 제어한다. 이후에 가까워졌다고 인식하면 구멍 너머의 표식을 인식하여 통과하고 회전임무를 수행한다. 

코드를 구현하기 위한 공간을 마련하기 위해 필요한 장비(천막, 봉) 구매와 강의실을 대여하여 환경을 구축하였다. 주어진 작업환경에서 코딩 후 즉시 적용해가며 이상적인 값과 실제 적용한 값과의 오차를 줄여나갔다. 




🎈 알고리즘 설명
====
1. 기기의 객체 선언 및 takeoff 진행한다.
2. 파란색 천막 인식 및 구멍을 이미지 처리한 후 드론 카메라에 표시되는 구멍의 위치에 따라 드론이 전진과 동시에 상하좌우로 제어한다.
3. 구멍에 충분히 가까워졌다고 판단되면 구멍을 이용한 제어는 멈추고 이후의 표식을 인식한다. 
4. 인식한 표식까지 전진한 후, 회전 임무를 수행한다. (2단계에서 2-3번을 반복진행)


🎈 단계별 시행착오
====
* 1단게 통과 방식
초기에 1단게 통과절차의 구상은 다음과 같았다.
<pre>
 %% 상하 구동 결정 함수
    while 1
        %이미지 처리(RGB->HSV)
        frame = snapshot(cam);
        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        [height, ] = readHeight(drone); %드론 현재 높이 받아오기

        if mission == 1 %미션 1 수행_상하 컨트롤
            disp('미션 1 수행 중');
            if abs(height-0.9) > 0.2 %절댓값으로 확인
                if height < 0.9
                    moveup(drone,'Distance',0.9-height)
                    break;
                else
                    movedown(drone,'Distance',height-0.9)
                    break;
                end
            end
</pre>

장애물이 측면으로 움직인다는 변수가 없고 드론이 정면을 봤을 때, 통과해야하는 구멍이 처음부터 중앙에 있다는 점과 장애물 밑단의 길이가 50cm라고 가정했
높이에 대한 값만 받은 후 


🎈 소스코드 설명
====
소스코드는 앞서 설명한 알고리즘에 따라 순차적으로 작성하였다. 더 상세한 설명은 각 코드별 주석에서 확인할 수 있다.

----
1. 기기의 객체 선언 및 takeoff
<pre>
%% 변수 선언
count = 0;
detection = [false false];

red_h_min1 = 0; red_h_max1 = 0.05; red_h_min2 = 0.95; red_h_max2 = 1; red_s_min = 0.6; red_s_max = 1;
pur_h_min = 0.7; pur_h_max = 0.85; pur_s_min = 0.4; pur_s_max = 1;
gre_h_min = 0.3; gre_h_max = 0.4; gre_s_min = 0.4; gre_s_max = 1;
blu_h_min = 0.55; blu_h_max = 0.7; blu_s_min = 0.5; blu_s_max = 0.9;

%% 객체 선언  
drone = ryze(); %드론 객체 선언
cam = camera(drone);

%% Main 함수
takeoff(drone);
</pre>
-------------
2. 구멍 이미지 및 구멍 위치에 따라 일정한 시간간격으로 전진하는 드론을 상하좌우로 제어
<pre>
for mission = 1:3
    if mission == 1
        disp('미션 1 수행중');
    
    elseif mission == 2
        disp('미션 2 수행중');
        
    elseif mission == 3
        disp('미션 3 수행중');  
    end
 
    %% 원 통과 함수(Blue Screen Detection)
    while 1
        disp('원 탐색 수행');
        %이미지 처리(RGB->HSV)
        frame = snapshot(cam);
        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        
        blue_screen = (blu_h_min<h)&(h<blu_h_max)&(blu_s_min<s)&(s<blu_s_max); %파랑색 검출
        circle = imfill(blue_screen,'holes'); %빈공간 채우기
         
        for x=1:size(blue_screen,1)
            for y=1:size(blue_screen,2)
                if blue_screen(x,y)==circle(x,y)
                    circle(x,y)=0;  %동일한 부분을 0으로 처리함으로써 원만 추출
                end
            end
        end
       
        %hole 식별
        if sum(circle,'all') > 10000 
            disp('hole 탐색 완료!');
            count = 0;
            break;

        %hole 미식별
        else
            %화면의 좌우, 상하를 비교
            diff_lr = sum(imcrop(blue_screen,[0 0 480 720]),'all') - sum(imcrop(blue_screen,[480 0 960 720]),'all');
            diff_ud = sum(imcrop(blue_screen,[0 0 960 360]),'all') - sum(imcrop(blue_screen,[0 360 960 720]),'all');
            
            if count == 4
                moveforward(drone, 'distance', 0.2, 'speed', 0.5);
                disp('기동 횟수 초과에 따른 직진');
                count = 0;
            
            else
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
                
                if mission == 3
                    turn(drone, deg2rad(3));
                    disp('3도 회전');
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
        
        if circle_area >= 80000 && mission ~= 3
            disp('표식 탐색으로 진행');
            break;
        end
        
        if mission == 3
            purple = (pur_h_min<h) & (h<pur_h_max) & (pur_s_min<s) & (s<=pur_s_max);
            purple_detect_area = regionprops(purple, 'Centroid', 'Area');
            purple_area = 0;
            for j = 1:length(purple_detect_area)
                if purple_area <= purple_detect_area(j).Area %가장 큰 영역 추출을 위하여 Area를 이용한 처리
                    purple_area = purple_detect_area(j).Area;
                    purple_center = purple_detect_area(j).Centroid;
                end
            end
            
            if purple_area ~= 0
                if purple_center(1) - circle_center(1) > 50
                    turn(drone, deg2rad(3));

                elseif purple_center(1) - circle_center(1) < - 50
                    turn(drone, deg2rad(-3));

                else
                    break;
                end
            end    
        end
 
        if circle_area ~= 0
            if (420 <= round(circle_center(1)) && 540 >= round(circle_center(1))) && (120 <= round(circle_center(2)) && 220 >= round(circle_center(2)))
                    
                if circle_area >= 50000
                    disp('충분한 크기의 원 탐색 완료');
                    break;
                    
                else
                    moveforward(drone, 'Distance', 0.6, 'speed', 1);
                end

            elseif 420 > round(circle_center(1))
                moveleft(drone, 'Distance', 0.2, 'speed', 0.5);
                disp('자세 제어를 위해 좌측으로 이동');

            elseif 540 < round(circle_center(1))
                moveright(drone, 'Distance', 0.2, 'speed', 0.5);
                disp('자세 제어를 위해 우측으로 이동');

            elseif 120 > round(circle_center(2))
                moveup(drone, 'Distance', 0.2, 'speed', 0.5);
                disp('자세 제어를 위해 위로 이동');

            elseif 220 < round(circle_center(2))
                movedown(drone, 'Distance', 0.2, 'speed', 0.5);
                disp('자세 제어를 위해 아래로 이동');
            end
        end
        
        
    end
</pre>

----
3. 표식 이미지 처리 & 인식 및 회전임무 수행
<pre>
 %% 표식 찾기 함수
    while 1
        %이미지 처리(RGB->HSV)
        frame = snapshot(cam);
        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
 
        if mission == 1 %원 통과 후 점 찾기(red)
            red = ((red_h_min1<h) & (h<red_h_max1) | (red_h_min2<h) & (h<red_h_max2)) & (red_s_min<s) & (s<=red_s_max);
            
            imshow(red);
            
            
            if sum(red, 'all') ~= 0
                if sum(red, 'all') > 2000
                    moveforward(drone, 'distance', 0.2);
                    disp('미션 1 표식 감지');
                    turn(drone, deg2rad(90));
                    moveforward(drone, 'distance', 1);
                    break;
                    
                elseif 50 < sum(red, 'all') && sum(red, 'all') < 2000
                    disp('미션 1 표식 멀리 있음');
                    moveforward(drone, 'distance', 0.5);
                    
                end
            end
            
        elseif mission == 2 %원 통과 후 점 찾기(green)
            green = (gre_h_min<h) & (h<gre_h_max) & (gre_s_min<s) & (s<=gre_s_max);
            imshow(green);
            if sum(green, 'all') ~= 0
                if sum(green, 'all') > 2000
                    moveforward(drone, 'distance', 0.3);
                    disp('미션 2 표식 감지');
                    turn(drone, deg2rad(90));
                    moveforward(drone, 'distance', 1);
                    break;
                    
                elseif 50 < sum(green, 'all') && sum(green, 'all') < 2000
                    disp('미션 2 표식 멀리 있음');
                    moveforward(drone, 'distance', 0.5);
                end
            end
            
        elseif mission == 3  %원 통과 후 점 찾기(purple)
            purple = (pur_h_min<h) & (h<pur_h_max) & (pur_s_min<s) & (s<=pur_s_max);
            imshow(purple);
            if sum(purple, 'all') ~= 0
                if sum(purple, 'all') > 2000
                    disp('미션 3 표식 감지');
                    land(drone);
                    break;
                    
                elseif 50 < sum(purple, 'all') && sum(purple, 'all') < 2000
                    disp('미션 3 표식 멀리 있음');
                    moveforward(drone, 'distance', 0.2);
                end     
            end
        end
    end
</pre>
----

