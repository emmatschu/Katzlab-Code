'''
Emma Schumacher
Katzlab
Spring 2022

Code to visualize germline soma sequences by organizing data into objects
''' 

class Sequence: 
    def __init__(self, name, start, end, size, gaplen = 0, rev = False, flip = False):
        #initializes my variables
        self.name = name 
        self.start = start
        self.end = end
        self.size = size
        self.gaplen = gaplen
        self.rev = rev
        self.flip = flip
    
    #########GETTERS AND SETTERS###########
        
    #returns the transcript name
    def get_name(self):
        return self.name
    
    #sets the transcript name
    def set_name(self, idnum):
        self.name = idnum

    #returns the s0start location
    def get_start(self):
        return self.start
    
    #sets the s0start location
    def set_start(self, coor):
        self.start = coor

    #returns the s0end location
    def get_end(self):
        return self.end
    
    #sets the s0end location
    def set_end(self, coor):
        self.end = coor

    #returns the size
    def get_size(self):
        return self.size
    
    #sets the size
    def set_size(self):
        self.size = self.end - self.start 

    #returns the gaplen
    def get_gaplen(self):
        return self.gaplen
    
    #sets the size
    def set_gaplen(self, leng):
        self.gaplen = leng
        
    #returns the rev boolean
    def get_rev(self):
        return self.rev
    
    #sets the rev boolean
    def set_rev(self, ver):
        self.rev = ver

    #sets the rev boolean
    def check_rev(self):
        if (self.start > self.end): 
            self.rev = True
            temp = self.start
            self.start = self.end
            self.end = temp
            del temp
            
    #sets the rev boolean
    def get_rev(self):
        return(self.rev) 
            
    #sets the flip boolean
    def set_flip(self, flp):
        self.flip = flp

    #sets the rev boolean
    def get_flip(self):
        return self.flip
        
class Germline(Sequence): 
    def __init__(self, name, start, end, size, gaplen, germ, rev = False, flip = False):
        #initializes my variables
        Sequence.__init__(self, name, start, end, size, gaplen, rev = False, flip = False)
        self.germ = germ  
        
    #finds length of sequence
    def get_length(self):
        return(self.end - self.start)

    #finds overlap with next sequence
    def get_overlap(self, nextstart):
        if (self.end > nextstart):
            return (self.end - nextstart)
        else:
            return(0)
    
    #returns the germline name
    def get_germ(self):
        return self.germ
    
    #sets the transcript name
    def set_germ(self, idnum):
        self.germ = idnum

        
class Soma(Sequence): 
    def __init__(self, name, start, end, size, gaplen, rev = False, flip = False, somagap = False):
        #initializes my variables
        Sequence.__init__(self, name, start, end, size, gaplen, rev = False, flip = False)
        self.somagap = somagap
                
    #returns the biggap boolean
    def get_somagap(self):
        return self.somagap
    
    #sets the scram boolean
    def set_somagap(self, ver):
        self.somagap = ver
    
 
#s1 = Sequence(337, 5, 157, 7329, 7481)
#s1.myfunc()

