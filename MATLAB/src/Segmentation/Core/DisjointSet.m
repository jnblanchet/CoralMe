classdef DisjointSet < handle
    %DISJOINTSET structure, useful for id merging
    % Jean-Nicola Blanchet (c) 2016
    
    properties
        count
        parent
        rank
    end
    
    methods
        function this = DisjointSet(count)
            this.count = count;
            this.parent = 1:count;
            this.rank = zeros(count,1);
        end
        
        function id = find(this, i)
            if (this.parent(i) == i)
                id = i;
            else
                this.parent(i) = this.find(this.parent(i));
                id = this.parent(i);
            end
        end
        
        function newid = union(this, i, j)
            if (i == j)
                newid = i;
                return;
            end
            
            iroot = this.find(i);
            jroot = this.find(j);
            irank = this.rank(iroot);
            jrank = this.rank(jroot);
            if (iroot == jroot)
                newid = iroot;
                return;
            end
            
            if (irank < jrank)
                newid = jroot;
                this.parent(iroot) = jroot;
            elseif (jrank < irank)
                newid = iroot;
                this.parent(jroot) = iroot;
            else
                newid = jroot;
                this.parent(iroot) = jroot;
                this.rank(iroot) = this.rank(iroot) + 1;
            end
        end
    end
end
