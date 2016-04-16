function [ out ] = callMethod( handle, args )
%CALLMETHOD Calls a method with the proper number of arguments
% There is probably a cleaner way of doing this, but I haven't found it yet
switch numel(args)
    case 0
        out = handle();
    case 1
        out = handle(args{1});
    case 2
        out = handle(args{1},args{2});
    case 3
        out = handle(args{1},args{2},args{3});
    case 4
        out = handle(args{1},args{2},args{3},args{4});
    case 5
        out = handle(args{1},args{2},args{3},args{4},args{5});
    case 6
        out = handle(args{1},args{2},args{3},args{4},args{5},args{6});
    case 7
        out = handle(args{1},args{2},args{3},args{4},args{5},args{6},args{7});
    case 8
        out = handle(args{1},args{2},args{3},args{4},args{5},args{6},args{7},args{8});
    case 9
        out = handle(args{1},args{2},args{3},args{4},args{5},args{6},args{7},args{8},args{9});
    case 10
        out = handle(args{1},args{2},args{3},args{4},args{5},args{6},args{7},args{8},args{9},args{10});
    otherwise
        error('Too many arguments! extend the callMethod function!')
end

end

