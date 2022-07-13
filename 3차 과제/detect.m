function [center_x, center_y] = detect(input)

    image = imread(input);
    th_down = 0.30;
    th_up = 0.36;

    hsv_img = rgb2hsv(image); %rgb를 hsv로 변환
    h = hsv_img(:,:,1);
    s = hsv_img(:,:,2);
    binary_img = (th_down<h)&(h<th_up)&(s>0.5);
    filter_img = imcomplement(binary_img);

    detect_area = regionprops(filter_img,'BoundingBox','Area'); %영상 영역의 속성 측정; BoundingBox와 Area 값 추출
    tmp_area = 0;
    for j = 1:length(detect_area)
        tmp_box = detect_area(j).BoundingBox; 
        if(tmp_box(3) == 960 || tmp_box(4) == 720) %화면 전체에 대한 BoundingBox 예외 처리
            continue
        
        else
            if tmp_area <= detect_area(j).Area %가장 큰 영역 추출을 위하여 Area를 이용한 처리
                tmp_area = detect_area(j).Area;
                filter_BoundingBox = detect_area(j).BoundingBox; %가장 큰 영역을 filter_BoundingBox 배열에 저장
            end
        end
    end
    figure, imshow(image)
    hold on
    rectangle('Position', [filter_BoundingBox(1),filter_BoundingBox(2),filter_BoundingBox(3),filter_BoundingBox(4)],'EdgeColor','y','LineWidth',2);
    % 중앙 값 추출
    center_x = filter_BoundingBox(1) + (0.5 * filter_BoundingBox(3)); %좌상단 x값 + 가로 길이/2
    center_y = filter_BoundingBox(2) + (0.5 * filter_BoundingBox(4)); %좌상단 y값 + 세로 길이/2
    plot(center_x, center_y,'o')
    axis on
    grid on
end

[x,y] = detect("문제1.png")