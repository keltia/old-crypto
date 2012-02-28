
Disrupted transposition

     E F G J B C D I A H  K  L  M
     4 5 6 9 1 2 3 8 0 7 10 11 12
						 xlen
                     /----------\
                     0 1  2  3  4
 col 0 1 2 3 4 5 6 7 8 9 10 11 12
row
 0                   * *  *  *  *\
 1                     *  *  *  * |
 2                        *  *  * | ylen
 3                           *  * |
 4                              */
 5           * * * * * *  *  *  *\
 6             * * * * *  *  *  * |
 7               * * * *  *  *  * |
 8                 * * *  *  *  * | ylen
 9                   * *  *  *  * |
10                     *  *  *  * |
11                        *  -  - /
             \__________________/
			         xlen

size = # of '*'
complete = boolean

13 x 12 = 156
156 / 13 = 12
totalx = 13		pos + xlen
totaly = 12

        maxy
ylen = a[-1][0] - start_row

len = 65

    C O N S P I R A C Y
    1 5 4 8 6 3 7 0 2 9
	0 1 2 3 4 5 6 7 8 9
    -------------------			HoleArea.new(0, 7, 3, 65)
  0               * * *
  1  		 	    * *
  2  			      *
  3 * * * * * * * * * * 		HoleArea.new(3, 0, 10, 65) -> totalx = 10
  4   * * * * * * * * *									 	  totaly = 6
  5     * * * * * * * *
  6       * * - - - - -

    C O N S P I R A C Y
    1 5 4 8 6 3 7 0 2 9
	0 1 2 3 4 5 6 7 8 9
    -------------------			HoleArea.new(0, 7, 3, 65)
  0 w e c o n f i E N T
  1 r m t h e d e l S A
  2 i v	e r	y o f t h N
  3 D W I L L S E N D F 		HoleArea.new(3, 0, 10, 65) -> totalx = 10
  4 e U R T H E R I N S									 	  totaly = 6
  5 d o T R U C T I O N
  6 c u m S X - - - - -

    C O N S P I R A C Y
    1 5 4 8 6 3 7 0 2 9
	0 1 2 3 4 5 6 7 8 9
    -------------------			HoleArea.new(0, 7, 3, 65)
  0 w e c o n f i E N T
  1 r m t h e d e l S A
  2 i v	e r	y o f t h N
  3 D W I L L S E N D F 		HoleArea.new(3, 0, 10, 65) -> totalx = 10
  4 e U R T H E R I N S									 	  totaly = 6
  5 d o T R U C T I O N
  6 c u m S X - - - - -


EltNII wriDedc NShDNO fdoSEC cteIRTm emvWUou neyLHUX iefERT ohrLTRS TANFSN

     E F D J C B A I G H 
     4 5 3 9 2 1 0 8 6 7 
			  	  xlen
                 /-----\
                 0 1 2 3
 col 0 1 2 3 4 5 6 7 8 9
row
 0               * * * * \
 1                 * * * |
 2                   * * | ylen
 3                     * /
 4             * * * * * \          
 5               * * * * |
 6                 * * * | ylen
 7                   * * |
 8                     * /
 9           * * * * * * \
10             * * * * * | ylen
11               * * - - /
             \_________/
			    xlen
