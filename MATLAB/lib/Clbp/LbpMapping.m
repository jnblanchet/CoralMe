function mapping = LbpMapping(samples,mappingtype)
%{
    CW_LBPMapping

	Returns a mapping table for LBP codes.
    MAPPING = CW_LBPMapping(SAMPLES, MAPPINGTYPE)
    returns a mapping for LBP codes in a neighbourhood of SAMPLES sampling
    points. Possible values for MAPPINGTYPE are
        'u2'   for uniform LBP
        'ri'   for rotation-invariant LBP
        'riu2' for uniform rotation-invariant LBP.

     Example:
          I=imread('rice.tif');
          MAPPING=getmapping(16,'riu2');
          LBPHIST=lbp(I,2,16,MAPPING,'hist');
     Now LBPHIST contains a rotation-invariant uniform LBP
     histogram in a (16,2) neighbourhood.

   
    History
        Marko Heikkilä and Timo Ahonen    
%}
   % 
   mapping = 0:2^samples-1;
   
   switch (mappingtype)
      % Uniform 2
      case 'u2'
         index = 0;
         newMax = samples * (samples - 1) + 3; 
         for i = 0:2^samples-1
            % Rotate left
            j = bitset(bitshift(i,1,samples),1,bitget(i,samples)); 
            % number of 1->0 and 0->1 transitions in binary string 
            % x is equal to the number of 1-bits in
            % XOR(x,Rotate left(x)) 
            numt = sum(bitget(bitxor(i,j),1:samples)); 
            if numt <= 2
               mapping(i+1) = index;
               index = index + 1;
            else
               mapping(i+1) = newMax - 1;
            end
         end
         
      % Rotation invariant
      case 'ri'
         newMax  = 0;
         tmpMap = zeros(2^samples) - 1;
         for i = 0:2^samples-1
            rm = i;
            r  = i;
            for j = 1:samples-1
               % Rotate left
               r = bitset(bitand(bitshift(r,1),bitshift(1,samples) - 1),1,bitget(r,samples)); %rotate left
               if r < rm
                  rm = r;
               end
            end
            if tmpMap(rm+1) < 0
               tmpMap(rm+1) = newMax;
               newMax = newMax + 1;
            end
            mapping(i+1) = tmpMap(rm+1);
         end
         
      % Uniform & Rotation invariant
      case 'riu2'
         for i = 0:2^samples - 1
            j = bitset(bitand(bitshift(i,1),bitshift(1,samples) - 1),1,bitget(i,samples)); %rotate left
            numt = sum(bitget(bitxor(i,j),1:samples));
            if numt <= 2
               mapping(i+1) = sum(bitget(i,1:samples));
            else
               mapping(i+1) = samples+1;
            end
         end
         
      % Unsupported
      otherwise
         disp('');
   end
   
end
