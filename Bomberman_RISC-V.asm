#All rights reserved
#Copyright belongs to Ernesto Rivera
#You can use this code freely in your project(s) as long as credit is given :)

#Inspiration taken from a MIPS assembly version done by: https://github.com/AndrewHamm/MIPS-Pong for the 
#MARS emulator

#The official repository of the RARS emulator can be found in: https://github.com/TheThirdOne/rars

# To run the project:
# 1) In the upper bar go to Run->Assemble (f3)
# 2) In the upper bar go to Tools->Bitmap Display
# 3) Configure the following settings in in the Bitmap Display:
	# a) Unit Width: 8
	# b) Unit Height: 8
	# c) Display Width: 512
	# d) Display Height: 256
	# e) Base Address: gp
	# f) Press connect to program 
# 4) In the upper bar go to Tools->Keyboard and Display MMIO Simulator and press connect to MIPS
# 5) In the upper bar go to Run->Go (f5)
# 6) Click on the lower window of the Keyboard and Display simulator to produce inputs

#Player movement is w and s for the left player and o and l for the right player.

#FOR THE STUDENTS: Internal labels of a function starts with a .

# Here I define the constants that will be used along the code
.eqv TOTAL_PIXELS, 8192 # The total ammount of pixels in the screen
.eqv FOUR_BYTES, 4 # The displacement in memory is done words which equals four bytes

.eqv TITLE_SCREEN_FIRST_LINE_ROW_Y, 1
.eqv TITLE_SCREEN_SECOND_LINE_ROW_Y, 28

.eqv PONG_TEXT_X, 6
.eqv PONG_TEXT_Y, 5
.eqv PONG_TEXT_H, 6

.eqv PRESS_TEXT_X, 9
.eqv PRESS_TEXT_Y, 16
.eqv PRESS_TEXT_H, 4



.eqv KEY_INPUT_ADDRESS 0xFFFF0004
.eqv KEY_STATUS_ADDRESS 0xFFFF0000
# For reference of those addreses check https://www.it.uu.se/education/course/homepage/os/vt18/module-1/memory-mapped-io/

.eqv ASCII_1 0x00000031
.eqv ASCII_2 0x00000032

.eqv MOV_UP 1
.eqv MOV_DOWN 2
.eqv MOV_LEFT 4
.eqv MOV_RIGHT 3
.eqv MOV_STAY 0

.eqv bomb  5
.eqv bomb_2 6
.eqv RANDOM 10
.eqv INITIAL_PADDLE_POSITION 13

.eqv INITIAL_BALL_X_POS 32
.eqv INITIAL_BALL_Y_POS 7

.eqv SCORE_FIRST_ROW_POINTS 5
.eqv SCORE_SECOND_ROW_POINTS 6
.eqv ROW_1 1
.eqv ROW_3 3
.eqv P1_SCORE_COLUMN 1
.eqv P2_SCORE_COLUMN 54
.eqv GAME_WIN_POINTS 10

.eqv PADDLE_LENGTH 0

.eqv TOP_PADDLE_Y_ROW 0
.eqv BOTTOM_PADDLE_Y_ROW 31 #  31 - 5 = 26 Thats the lowest point that paddle y can reach
.eqv BOTTOM_LEFT 0
.eqv BOTTOM_RIGHT 63

.eqv PLAYER_1_PADDLE_X_POS 0
#.eqv PLAYER_2_PADDLE_X_POS 50

.eqv PADDLE_X_MIN_LIMIT 1
.eqv PADDLE_X_MAX_LIMIT 59
.eqv FIRST_COLUMN 0
.eqv LAST_COLUMN 63

.eqv BALL_RIGHT_DIR 1
.eqv BALL_LEFT_DIR -1
.eqv BALL_UP_DIR -1
.eqv BALL_DOWN_DIR 1

.eqv BALL_Y_VELOCITY_REDUCTION -1

.eqv LEFT_COLLISION_X_POS 14
.eqv RIGHT_COLLISION_X_POS 49

# The constants for the ball-pallet collision position
.eqv TOP_HIGH 0
.eqv TOP_MID 1
.eqv TOP_LOW 2
.eqv BOTTOM_HIGH 3
.eqv BOTTOM_MID 4
.eqv BOTTOM_LOW 5

# The horizontal wall limists
.eqv Y_DOWN_LIMIT 31
.eqv Y_UP_LIMIT 0

.eqv Y_MAX_COLLISION_VELOCITY 1

# Player modes
.eqv ONE_PLAYER_MODE 1
.eqv TWO_PLAYER_MODE 2


# ASSCII characters

.eqv ASCII_W 119
.eqv ASCII_S 115
.eqv ASCII_A 97
.eqv ASCII_D 100
.eqv ASCII_SPACE 32 
.eqv ASCII_B 98
.eqv ASCII_N 110 

# The coordinmates of the end game screen

.eqv P_CHAR_WIN_X 26
.eqv P_CHAR_WIN_Y 5
.eqv P_CHAR_WIN_H 5

.eqv PLAYER_NUM_WIN_X 33
.eqv PLAYER_NUM_WIN_Y 5
.eqv PLAYER_NUM_WIN_H 5

.eqv WINS_TEXT_X, 18
.eqv WINS_TEXT_Y, 12
.eqv WINS_TEXT_H, 5

.eqv TIMER_LIMIT 10
.eqv TIMER_GAME_LIMIT 56



 # Begin of the data section
.data	
	timer:			.word 0
	timer_pos:		.word 20
	timer_game:             .word 0

	TEMP_LIMIT_2:    .word 50
        TEMP_LIMIT:     .word 30
	color_white:	.word 0x00ffffff
	color_pink:     .word 0x00FF00FF
	color_black:	.word 0x00000000
	color_red:	.word 0x00ff0000
	color_cyan: 	.word 0x0000ffff
	color_orange:	.word 0x00ffa500
	color_gray:     .word 0x00808080
	color_blue:     .word 0x000000ff
	color_green:    .word 0x0000ff00
	color_yellow:   .word 0x00FFFF00
	color_purple:   .word 0x800080
	color_brown:	.word 0xc19a6b00
	color_lblue:	.word 0x0000CCFF 
	color_rosybrown:.word 0x00bc8f8f
	color_burdeos:  .word 0x800020
	
	player_mode:	.word 0
		
	ball_x_dir:		.word BALL_DOWN_DIR	    # The ball starts going right
	ball_y_speed:		.word -1	# The wait steps before moving in the y axis
	ball_y_dir:		.word -1	# The ball starts going down
	p1_score:		.word 0
	p2_score: 		.word 0
	computer_count:	.word 0
	computer_speed:	.word 0		#Used after first collision
	level:		.word 6	
	
	player_x:	.word 6   
	player_y:	.word 5  
	
	enemy_x:        .word 10
	enemy_y:        .word 6
	
	enemy_x_2:      .word 30
	enemy_y_2:      .word 7
	
	enemy_x_3:      .word 30
	enemy_y_3:      .word 29
	
	random_seed:    .word 1234
	random_seed_2:  .word 5678
	random_seed_3:  .word 9456  
	 
	exp_x_1:        .word 0
	exp_y_1:        .word 0
	exp_x_2:        .word 0
	exp_y_2:        .word 0	
	exp_x_3:        .word 0
	exp_y_3:        .word 0
	exp_x_4:        .word 0
	exp_y_4:        .word 0
	explo_x_1:      .word 0
	explo_y_1:      .word 0
	explo_x_2:      .word 0
	explo_y_2:      .word 0	
	explo_x_3:      .word 0
	explo_y_3:      .word 0
	explo_x_4:      .word 0
	explo_y_4:      .word 0
	
	expb2_x_1:        .word 0
	expb2_y_1:        .word 0
	expb2_x_2:        .word 0
	expb2_y_2:        .word 0	
	expb2_x_3:        .word 0
	expb2_y_3:        .word 0
	expb2_x_4:        .word 0
	expb2_y_4:        .word 0
	explob2_x_1:      .word 0
	explob2_y_1:      .word 0
	explob2_x_2:      .word 0
	explob2_y_2:      .word 0	
	explob2_x_3:      .word 0
	explob2_y_3:      .word 0
	explob2_x_4:      .word 0
	explob2_y_4:      .word 0
	
	power_1_x:      .word 30
	power_1_y:      .word 15
	power_2_x:      .word 10
	power_2_y:      .word 20
	power_3_x:      .word 6
	power_3_y:      .word 10
	Patin_count:     .word 0
	count_power:    .word 0
	count_power_2:  .word 0
	temporizador:   .word 0
	temporizador_2: .word 0
	temporizador_b2:   .word 0
	temporizador_2b2: .word 0
	bomb_x:         .word 0
	bomb_y:         .word 0
	bomb_x_2:	.word 0
	bomb_y_2:	.word 0
	count_bomb:     .word 0
	init_bomb:      .word 0
	init_bomb_2:    .word 0
	no_bomb:        .word 0
	erase_enemy:    .word 0
	erase_enemy_2:  .word 0
	erase_enemy_3:  .word 0
	enemy_count:    .word 0
	count_lifes:    .word 0
	count_lifes_1:  .word 0	
	count_lifes_2:  .word 0	
	count_portal:   .word 0
	count_score:    .word 0
	count_level:    .word 0
	count_level_1:  .word 0
	level_1_load:   .word 0
	level_2_load:   .word 0
	level_3_load:   .word 0

	.text
#####################################################################################################################33
new_game:
	
	jal clear_board
	jal draw_title_screen
	
	select_1_or_2_players:
    	lw t0, KEY_INPUT_ADDRESS # Verify if the player pressed an input
    	li t1, ASCII_SPACE

    	beq t0, t1, one_player_mode
    	li t1, ASCII_2
    	beq	t0, t1, two_player_mode
    	
    	li a0, 250
    	li a7, 32
    	ecall
    	
    	li t0, 0
    	sw t0, count_lifes, t1
    	sw t0, count_lifes_1, t1
    	sw t0, count_lifes_2, t1
    	sw t0, count_portal, t1
    	sw t0, count_level, t1
    	sw t0, count_level_1, t1
    	sw t0, count_power, t1
    	sw t0, count_power_2, t1
     	sw t0, count_score, t1
     	sw t0, count_bomb, t1
	sw t0, Patin_count, t1    	  	
	li t0, 0
    	sw t0, erase_enemy, t2
    	sw t0, erase_enemy_2, t2
    	sw t0, erase_enemy_3, t2
	sw t0, timer, t2
	sw t0, timer_game, t2
	
	li a0, 10
	li a1, 6
	sw a0, enemy_x, t2
	sw a1, enemy_y, t2
    	li a0, 30
	li a1, 7
	sw a0, enemy_x_2, t2
	sw a1, enemy_y_2, t2
	li a0, 30
	li a1, 29
	sw a0, enemy_x_3, t2
	sw a1, enemy_y_3, t2
	
	li a0, 6
	li a1, 5
	sw a0, player_x, t2
	sw a1, player_y, t2
	
	li a0, 30
	li a1, 15
	sw a0, power_1_x, t2
	sw a1, power_1_y, t2
	
	li a0, 10
	li a1, 20
	sw a0, power_2_x, t2
	sw a1, power_2_y, t2
	
	li a0, 6
	li a1, 10
	sw a0, power_3_x, t2
	sw a1, power_3_y, t2
    	
    	j select_1_or_2_players # If a key was not pressed go back to the loop
    	
    one_player_mode:
    	li t0, 1
    	sw t0, player_mode, t1
    	j start_game
    
    two_player_mode:
    	li t0, 2
    	sw t0, player_mode, t1
    	j start_game
    	
    start_game:
    	sw zero, KEY_STATUS_ADDRESS, t0 # This clears the status if a key was pressed


        jal clear_board
    	jal draw_level_1	

###############################################################################################################################    	
# Function: new_round
#	The function does not have parameters, but due to speed internally uses the following convention
#		s0 stores the p1 dir
#		s1 stores the p2 dir
#		s2 stores thel ball x velocity
#		s3 stores the ball y velocity
#		s4 stores the player 1 paddle position
#		s5 stores the player 2 paddle position
#		s6 stores the ball x position
# 		s7 stores tghe ball y position
# This function is part of the main loop, so it does not require to save the state of the s registers
# but if it were an internal function, it should save each state.
Level_1:
  	li t3, 1
  	sw t3, level_1_load,t1
	
	lw a0, player_x
	lw a1, player_y
	lw a2, color_red
	li a3, MOV_STAY
	jal draw_player
	jal draw_lifes
	jal draw_walls
	jal draw_solid_blocks
	jal draw_destructible

	jal draw_enemies
	jal draw_enemies_2
	jal draw_enemies_3
	jal draw_portal
	jal draw_score_1
	jal draw_power
	jal draw_power_2
	jal draw_power_3
	li a0, 1000
	li a7, 32		
	ecall		# 1 second delay
	j main_game_loop
	
#################################################################################################################################
Level_2:

	li t3, 0
	sw t3, level_1_load,t1
	
	li t4, 1
	sw t4, level_2_load, t1
	sw t4, count_level, t1
	
	li t0, 0
    	sw t0, count_lifes, t1
    	sw t0, count_lifes_1, t1
    	sw t0, count_lifes_2, t1
	sw t0, timer, t2
	sw t0, timer_game, t2
    	sw t0, count_portal, t1
        sw t0, Patin_count, t1 
        
	li t0, 0
    	sw t0, erase_enemy, t2
    	sw t0, erase_enemy_2, t2
    	sw t0, erase_enemy_3, t2
    	
	li a0, 10
	li a1, 6
	sw a0, enemy_x, t2
	sw a1, enemy_y, t2
    	li a0, 30
	li a1, 7
	sw a0, enemy_x_2, t2
	sw a1, enemy_y_2, t2
	li a0, 30
	li a1, 29
	sw a0, enemy_x_3, t2
	sw a1, enemy_y_3, t2
	
	li a0, 6
	li a1, 5
	sw a0, player_x, t2
	sw a1, player_y, t2
	
	li a0, 6
	li a1, 10
	sw a0, power_3_x, t2
	sw a1, power_3_y, t2		
	
	lw a0, player_x
	lw a1, player_y
	lw a2, color_red
	li a3, MOV_STAY
	
	jal draw_player
	jal draw_lifes
	jal draw_walls
	jal draw_solid_blocks
	jal draw_destructible_2
	jal draw_enemies
	jal draw_enemies_2
	jal draw_enemies_3
	jal draw_portal
	jal draw_score_1
	jal draw_power
	jal draw_power_2
	jal draw_power_3
	li a0, 1000
	li a7, 32		
	ecall		# 1 second delay
	j main_game_loop
	
#################################################################################################################################
Level_3:
	li t3, 0
	sw t3, level_1_load,t1
	li t3, 0
	sw t3, level_2_load,t1	
	li t4, 1
	sw t4, level_3_load, t1
	sw t4, count_level_1, t1
	
	li t0, 0
    	sw t0, count_lifes, t1
    	sw t0, count_lifes_1, t1
    	sw t0, count_lifes_2, t1
	sw t0, timer, t2
	sw t0, timer_game, t2
    	sw t0, count_portal, t1
	sw t0, Patin_count, t1
	
	li t0, 0
    	sw t0, erase_enemy, t2
    	sw t0, erase_enemy_2, t2
    	sw t0, erase_enemy_3, t2
    	
	li a0, 10
	li a1, 6
	sw a0, enemy_x, t2
	sw a1, enemy_y, t2
    	li a0, 30
	li a1, 7
	sw a0, enemy_x_2, t2
	sw a1, enemy_y_2, t2
	li a0, 30
	li a1, 29
	sw a0, enemy_x_3, t2
	sw a1, enemy_y_3, t2
	
	li a0, 6
	li a1, 5
	sw a0, player_x, t2
	sw a1, player_y, t2
	
	li a0, 6
	li a1, 10
	sw a0, power_3_x, t2
	sw a1, power_3_y, t2

	lw a0, player_x
	lw a1, player_y
	lw a2, color_red
	li a3, MOV_STAY
	
	jal draw_player
	jal draw_lifes
	jal draw_walls
	jal draw_solid_blocks
	jal draw_destructible_3
	jal draw_enemies
	jal draw_enemies_2
	jal draw_enemies_3
	jal draw_portal
	jal draw_score_1
	jal draw_power
	jal draw_power_2
	jal draw_power_3
	
	li a0, 1000
	li a7, 32		
	ecall		# 1 second delay
	j main_game_loop

########################################################################################################################	
# Function: main_game_loop
# This function is the main game loop of the game when playing
#	The function does not have parameters, but due to speed internally uses the following conventions
#		s0 stores the p1 dir
#		s1 stores the p2 dir
#		s2 stores thel ball x velocity
#		s3 stores the ball y velocity
#		s4 stores the player 1 paddle position
#		s5 stores the player 2 paddle position
#		s6 stores the ball x position
# 		s7 stores the ball y position
# Return:
# 	void.
main_game_loop:
		
	
	
	
	.draw_objects:
	
	lw t0, timer
	li t1, TIMER_LIMIT
	
	bge t1, t0, .t_count
	
		li t0, 0
		sw t0, timer, t1
		
		lw t2, timer_game
		li t3 , TIMER_GAME_LIMIT
		bge t2, t3, .t_not_count
	 	
		li a0, 4
		add a0, a0, t2
		li a1, 2
		lw a2, color_white
		jal draw_point
		
		
		addi t2, t2, 1
		sw t2, timer_game, t1
				
		j .t_not_count
		
	.t_count:
	
		addi t0, t0, 1
		sw t0, timer, t2
		
		lw t0, timer_game
		li t1, 56
		bne t0, t1, .no_reset
		li a0, 4
		li a1, 2
		lw a2, color_black
		addi a3, a0, 55
		jal draw_horizontal_line
		li t0, 0
		sw t0, timer, t2
		sw t0, timer_game, t2
		
		#Contador de vidas
		li t0, 1
		sw t0,count_lifes, t2
		lw t0, count_lifes_1
		addi t0, t0, 1
		sw t0, count_lifes_1, t2
		lw t1, count_lifes_2
		addi t1, t1, 1
		sw t1, count_lifes_2, t2
		
		.no_reset:
		
	.t_not_count:
		
		
		#Inicia explocion solo cuando la bomba no este activa(iniciar contador)
		lw t0, init_bomb
		li t1, 1
		bne t0,t1, .no_temp
	tempo:		

		lw t0, temporizador
		lw t1, TEMP_LIMIT
		bge t1, t0, .count
		li t0, 0
		sw t0, temporizador, t1
		lw a0, bomb_x 
		lw a1, bomb_y
		lw a2, color_black
		jal draw_point
		
		#Colocar solo una bomba
		li t2, 0
     		sw t2, init_bomb, t1
     		
		#Explosion a la derecha
		lw t0, bomb_x
		lw t2, bomb_y
		addi a0,t0,1
		add a1, zero, t2
		sw a0, exp_x_1, t1
		sw a1, exp_y_1, t1
		lw a2, color_white
		jal draw_point
		

		#Compara enemigo 1 con la explosion derecha
		lw t0, enemy_x
		lw t1, enemy_y
		bne a0, t0, .other_1
		bne a1, t1, .other_1
		li t0, 1
		sw t0, erase_enemy, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		
				
		.other_1:
		#Compara enemigo 2 con la explosion derecha
		lw t0, enemy_x_2
		lw t1, enemy_y_2
		bne a0, t0, .other_2
		bne a1, t1, .other_2
		li t0, 1
		lw t0, erase_enemy_2
		addi t0, t0, 1
		sw t0, erase_enemy_2, t1
		#Contador de puntos
		li t4, 2
		lw t3, erase_enemy_2
		bne t4,t3, .other_2
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		
		.other_2:
		#Compara enemigo 3 con la explosion derecha
		lw t0, enemy_x_3
		lw t1, enemy_y_3
		bne a0, t0, .other_3
		bne a1, t1, .other_3
		li t0, 1
		sw t0, erase_enemy_3, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2	
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2

						
		.other_3:
		#Compara jugador con la explosion derecha
		lw t0, player_x
		lw t1, player_y
		bne a0, t0, .nothing_3
		bne a1, t1, .nothing_3
		li t0, 6
		li t1, 5
		sw t0, player_x, t2 
		sw t1, player_y, t2
		
		#Contador de vidas
		li t0, 1
		sw t0,count_lifes, t2
		lw t0, count_lifes_1
		addi t0, t0, 1
		sw t0, count_lifes_1, t2
		lw t1, count_lifes_2
		addi t1, t1, 1
		sw t1, count_lifes_2, t2
		
		.nothing_3:
				 
		#Explosion a la izquierda
		lw t0, bomb_x
		lw t2, bomb_y
		addi a0,t0,-1
		add a1, zero, t2
		sw a0, exp_x_2, t1
		sw a1, exp_y_2, t1
		lw a2, color_white
		jal draw_point
		
		#Compara enemigo 1 con la explosion izquierda
		lw t0, enemy_x
		lw t1, enemy_y
		bne a0, t0, .other_4
		bne a1, t1, .other_4
		li t0, 1
		sw t0, erase_enemy, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		
		.other_4:
		#Compara enemigo 2 con la explosion izquierda
		lw t0, enemy_x_2
		lw t1, enemy_y_2
		bne a0, t0, .other_5
		bne a1, t1, .other_5
		li t0, 1
		lw t0, erase_enemy_2
		addi t0, t0, 1
		sw t0, erase_enemy_2, t1
		#Contador de puntos
		li t4, 2
		lw t3, erase_enemy_2
		bne t4,t3, .other_5
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2

		.other_5:
		#Compara enemigo 3 con la explosion izquierda
		lw t0, enemy_x_3
		lw t1, enemy_y_3
		bne a0, t0, .other_6
		bne a1, t1, .other_6
		li t0, 1
		sw t0, erase_enemy_3, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2	
			
		.other_6:
		#Compara jugador con la explosion izquierda
		lw t0, player_x
		lw t1, player_y
		bne a0, t0, .nothing_2
		bne a1, t1, .nothing_2
		li t0, 6
		li t1, 5
		sw t0, player_x, t2 
		sw t1, player_y, t2
		
		#Contador de vidas
		li t0, 1
		sw t0,count_lifes, t2
		lw t0, count_lifes_1
		addi t0, t0, 1
		sw t0, count_lifes_1, t2
		lw t1, count_lifes_2
		addi t1, t1, 1
		sw t1, count_lifes_2, t2
		
		.nothing_2:
		#Explosion abajo
		lw t0, bomb_x
		lw t2, bomb_y
		addi a1,t2, 1
		add a0, zero, t0
		sw a0, exp_x_3, t1
		sw a1, exp_y_3, t1
		lw a2, color_white
		jal draw_point
				
		#Compara enemigo 1 con la explosion abajo
		lw t0, enemy_x
		lw t1, enemy_y
		bne a0, t0, .other_7
		bne a1, t1, .other_7
		li t0, 1
		sw t0, erase_enemy, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
					
		.other_7:
		#Compara enemigo 2 con la explosion abajo
		lw t0, enemy_x_2
		lw t1, enemy_y_2
		bne a0, t0, .other_8
		bne a1, t1, .other_8
		li t0, 1
		lw t0, erase_enemy_2
		addi t0, t0, 1
		sw t0, erase_enemy_2, t1
		#Contador de puntos
		li t4, 2
		lw t3, erase_enemy_2
		bne t4,t3, .other_8
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
			
		.other_8:
		#Compara enemigo 3 con la explosion abajo
		lw t0, enemy_x_3
		lw t1, enemy_y_3
		bne a0, t0, .other_9
		bne a1, t1, .other_9
		li t0, 1
		sw t0, erase_enemy_3, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2	
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2

					
		.other_9:
		#Compara jugador con la explosion abajo
		lw t0, player_x
		lw t1, player_y
		bne a0, t0, .nothing_1
		bne a1, t1, .nothing_1
		li t0, 6
		li t1, 5
		sw t0, player_x, t2 
		sw t1, player_y, t2
	
		#Contador de vidas
		li t0, 1
		sw t0,count_lifes, t2
		lw t0, count_lifes_1
		addi t0, t0, 1
		sw t0, count_lifes_1, t2
		lw t1, count_lifes_2
		addi t1, t1, 1
		sw t1, count_lifes_2, t2
		
		.nothing_1:
		#Explosion arriba
		lw t0, bomb_x
		lw t2, bomb_y
		addi a1,t2,-1
		add a0, zero, t0
		sw a0, exp_x_4, t1
		sw a1, exp_y_4, t1
		lw a2, color_white
		jal draw_point
				
		#Compara enemigo 1 con la explosion arriba
		lw t0, enemy_x
		lw t1, enemy_y
		bne a0, t0, .other_10
		bne a1, t1, .other_10
		li t0, 1
		sw t0, erase_enemy, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2	

						
		.other_10:
		#Compara enemigo 2 con la explosion arriba
		lw t0, enemy_x_2
		lw t1, enemy_y_2
		bne a0, t0, .other_11
		bne a1, t1, .other_11
		li t0, 1
		lw t0, erase_enemy_2
		addi t0, t0, 1
		sw t0, erase_enemy_2, t1
		#Contador de puntos
		li t4, 2
		lw t3, erase_enemy_2
		bne t4,t3, .other_11
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
			
		.other_11:
		#Compara enemigo 3 con la explosion arriba
		lw t0, enemy_x_3
		lw t1, enemy_y_3
		bne a0, t0, .other_12
		bne a1, t1, .other_12
		li t0, 1
		sw t0, erase_enemy_3, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2

						
		.other_12:
		#Compara jugador con la explosion arriba
		lw t0, player_x
		lw t1, player_y
		bne a0, t0, .nothing
		bne a1, t1, .nothing
		li t0, 6
		li t1, 5
		sw t0, player_x, t2 
		sw t1, player_y, t2
		
		#Contador de vidas
		li t0, 1
		sw t0,count_lifes, t2
		lw t0, count_lifes_1
		addi t0, t0, 1
		sw t0, count_lifes_1, t2
		lw t1, count_lifes_2
		addi t1, t1, 1
		sw t1, count_lifes_2, t2
		
		.nothing:
		#####################################################33
		#Explosion a la derecha x2
		li t4, 1
		lw t3, count_power
		bne t3, t4, .pw_18
		lw t0, bomb_x
		lw t2, bomb_y
		addi a0,t0,2
		add a1, zero, t2
		sw a0, explo_x_1, t1
		sw a1, explo_y_1, t1
		lw a2, color_white
		jal draw_point
	
		#Compara enemigo 1 con la explosion derecha x2
		lw t0, enemy_x
		lw t1, enemy_y
		bne a0, t0, .pw_1
		bne a1, t1, .pw_1
		li t0, 1
		sw t0, erase_enemy, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		
				
		.pw_1:
		#Compara enemigo 2 con la explosion derecha x2
		lw t0, enemy_x_2
		lw t1, enemy_y_2
		bne a0, t0, .pw_2
		bne a1, t1, .pw_2
		li t0, 1
		lw t0, erase_enemy_2
		addi t0, t0, 1
		sw t0, erase_enemy_2, t1
		#Contador de puntos
		li t4, 2
		lw t3, erase_enemy_2
		bne t4,t3, .pw_2
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
				
		.pw_2:
		#Compara enemigo 3 con la explosion derecha x2
		lw t0, enemy_x_3
		lw t1, enemy_y_3
		bne a0, t0, .pw_3
		bne a1, t1, .pw_3
		li t0, 1
		sw t0, erase_enemy_3, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2	
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2

						
		.pw_3:
		#Compara jugador con la explosion derecha x2
		lw t0, player_x
		lw t1, player_y
		bne a0, t0, .pw_4
		bne a1, t1, .pw_4
		li t0, 6
		li t1, 5
		sw t0, player_x, t2 
		sw t1, player_y, t2
		
		#Contador de vidas
		li t0, 1
		sw t0,count_lifes, t2
		lw t0, count_lifes_1
		addi t0, t0, 1
		sw t0, count_lifes_1, t2
		lw t1, count_lifes_2
		addi t1, t1, 1
		sw t1, count_lifes_2, t2
		
		.pw_4:
		############################
                #Explosion a la izquierda x2
                li t4, 1
		lw t3, count_power
		bne t3, t4, .pw_18
		lw t0, bomb_x
		lw t2, bomb_y
		addi a0,t0,-2
		add a1, zero, t2
		sw a0, explo_x_2, t1
		sw a1, explo_y_2, t1
		lw a2, color_white
		jal draw_point
		
		#Compara enemigo 1 con la explosion izquierda x2
		lw t0, enemy_x
		lw t1, enemy_y
		bne a0, t0, .pw_5
		bne a1, t1, .pw_5
		li t0, 1
		sw t0, erase_enemy, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		
		.pw_5:
		#Compara enemigo 2 con la explosion izquierda x2
		lw t0, enemy_x_2
		lw t1, enemy_y_2
		bne a0, t0, .pw_6
		bne a1, t1, .pw_6
		li t0, 1
		lw t0, erase_enemy_2
		addi t0, t0, 1
		sw t0, erase_enemy_2, t1
		#Contador de puntos
		li t4, 2
		lw t3, erase_enemy_2
		bne t4,t3, .pw_6
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2

		.pw_6:
		#Compara enemigo 3 con la explosion izquierda x2
		lw t0, enemy_x_3
		lw t1, enemy_y_3
		bne a0, t0, .pw_7
		bne a1, t1, .pw_7
		li t0, 1
		sw t0, erase_enemy_3, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2	
			
		.pw_7:
		#Compara jugador con la explosion izquierda x2
		lw t0, player_x
		lw t1, player_y
		bne a0, t0, .pw_8
		bne a1, t1, .pw_8
		li t0, 6
		li t1, 5
		sw t0, player_x, t2 
		sw t1, player_y, t2
		
		#Contador de vidas
		li t0, 1
		sw t0,count_lifes, t2
		lw t0, count_lifes_1
		addi t0, t0, 1
		sw t0, count_lifes_1, t2
		lw t1, count_lifes_2
		addi t1, t1, 1
		sw t1, count_lifes_2, t2
		
		.pw_8:
		#######################		
		#Explosion abajo x2
		li t4, 1
		lw t3, count_power
		bne t3, t4, .pw_18
		lw t0, bomb_x
		lw t2, bomb_y
		addi a1,t2, 2
		add a0, zero, t0
		sw a0, explo_x_3, t1
		sw a1, explo_y_3, t1
		lw a2, color_white
		jal draw_point
				
		#Compara enemigo 1 con la explosion abajo x2
		lw t0, enemy_x
		lw t1, enemy_y
		bne a0, t0, .pw_10
		bne a1, t1, .pw_10
		li t0, 1
		sw t0, erase_enemy, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
					
		.pw_10:
		#Compara enemigo 2 con la explosion abajo x2
		lw t0, enemy_x_2
		lw t1, enemy_y_2
		bne a0, t0, .pw_11
		bne a1, t1, .pw_11
		li t0, 1
		lw t0, erase_enemy_2
		addi t0, t0, 1
		sw t0, erase_enemy_2, t1
		#Contador de puntos
		li t4, 2
		lw t3, erase_enemy_2
		bne t4,t3, .pw_11
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
			
		.pw_11:
		#Compara enemigo 3 con la explosion abajo x2
		lw t0, enemy_x_3
		lw t1, enemy_y_3
		bne a0, t0, .pw_12
		bne a1, t1, .pw_12
		li t0, 1
		sw t0, erase_enemy_3, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2	
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2

					
		.pw_12:
		#Compara jugador con la explosion abajo x2
		lw t0, player_x
		lw t1, player_y
		bne a0, t0, .pw_13
		bne a1, t1, .pw_13
		li t0, 6
		li t1, 5
		sw t0, player_x, t2 
		sw t1, player_y, t2
	
		#Contador de vidas
		li t0, 1
		sw t0,count_lifes, t2
		lw t0, count_lifes_1
		addi t0, t0, 1
		sw t0, count_lifes_1, t2
		lw t1, count_lifes_2
		addi t1, t1, 1
		sw t1, count_lifes_2, t2
		
		.pw_13:
		#Explosion arriba x2
		li t4, 1
		lw t3, count_power
		bne t3, t4, .pw_18
		lw t0, bomb_x
		lw t2, bomb_y
		addi a1,t2,-2
		add a0, zero, t0
		sw a0, explo_x_4, t1
		sw a1, explo_y_4, t1
		lw a2, color_white
		jal draw_point
				
		#Compara enemigo 1 con la explosion arriba x2
		lw t0, enemy_x
		lw t1, enemy_y
		bne a0, t0, .pw_15
		bne a1, t1, .pw_15
		li t0, 1
		sw t0, erase_enemy, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2	

						
		.pw_15:
		#Compara enemigo 2 con la explosion arriba
		lw t0, enemy_x_2
		lw t1, enemy_y_2
		bne a0, t0, .pw_16
		bne a1, t1, .pw_16
		li t0, 1
		lw t0, erase_enemy_2
		addi t0, t0, 1
		sw t0, erase_enemy_2, t1
		#Contador de puntos
		li t4, 2
		lw t3, erase_enemy_2
		bne t4,t3, .pw_16
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
						
		.pw_16:
		#Compara enemigo 3 con la explosion arriba
		lw t0, enemy_x_3
		lw t1, enemy_y_3
		bne a0, t0, .pw_17
		bne a1, t1, .pw_17
		li t0, 1
		sw t0, erase_enemy_3, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2

						
		.pw_17:
		#Compara jugador con la explosion arriba
		lw t0, player_x
		lw t1, player_y
		bne a0, t0, .pw_18
		bne a1, t1, .pw_18
		li t0, 6
		li t1, 5
		sw t0, player_x, t2 
		sw t1, player_y, t2
		
		#Contador de vidas
		li t0, 1
		sw t0,count_lifes, t2
		lw t0, count_lifes_1
		addi t0, t0, 1
		sw t0, count_lifes_1, t2
		lw t1, count_lifes_2
		addi t1, t1, 1
		sw t1, count_lifes_2, t2
		
		.pw_18:		
		j .not_count
		
		.count:
			addi t0, t0, 1
			sw t0, temporizador, t1
			lw a0, bomb_x 
			lw a1, bomb_y
			lw a2, color_cyan
			jal draw_point
		.not_count:
		
		.no_temp:
		
	lw t0, init_bomb
	li t1, 0
	bne t0,t1, .no_temp_1
	
	tempo_2:
	
	        #Borra la explocion
		lw t0, temporizador_2
		lw t1, TEMP_LIMIT
		bge t1, t0, .count_2
		li t0, 0
		sw t0, temporizador_2, t1
		
		#Explosion a la derecha
		lw t0, bomb_x
		lw t2, bomb_y
		addi a0,t0,1
		add a1, zero, t2
		sw a0, exp_x_1, t1
		sw a1, exp_y_1, t1
		lw a2, color_black
		jal draw_point
		
		#Explosion a la derecha x2
		li t4, 1
		lw t3, count_power
		bne t3, t4, .ph
		lw t0, bomb_x
		lw t2, bomb_y
		addi a0,t0,2
		add a1, zero, t2
		sw a0, explo_x_1, t1
		sw a1, explo_y_1, t1
		lw a2, color_black
		jal draw_point
		.ph:
		#Explosion a la izquierda
		lw t0, bomb_x
		lw t2, bomb_y
		addi a0,t0,-1
		add a1, zero, t2
		sw a0, exp_x_2, t1
		sw a1, exp_y_2, t1
		lw a2, color_black
		jal draw_point
		#Explosion a la izquierda x2
		li t4, 1
		lw t3, count_power
		bne t3, t4, .ph_1
		lw t0, bomb_x
		lw t2, bomb_y
		addi a0,t0,-2
		add a1, zero, t2
		sw a0, explo_x_2, t1
		sw a1, explo_y_2, t1
		lw a2, color_black
		jal draw_point
		.ph_1:
		#Explosion arriba
		lw t0, bomb_x
		lw t2, bomb_y
		addi a1,t2, 1
		add a0, zero, t0
		sw a0, exp_x_3, t1
		sw a1, exp_y_3, t1
		lw a2, color_black
		jal draw_point
		#Explosion arriba x2
		li t4, 1
		lw t3, count_power
		bne t3, t4, .ph_2
		lw t0, bomb_x
		lw t2, bomb_y
		addi a1,t2, 2
		add a0, zero, t0
		sw a0, explo_x_3, t1
		sw a1, explo_y_3, t1
		lw a2, color_black
		jal draw_point
		.ph_2:
		#Explosion abajo
		lw t0, bomb_x
		lw t2, bomb_y
		addi a1,t2,-1
		add a0, zero, t0
		sw a0, exp_x_4, t1
		sw a1, exp_y_4, t1
		lw a2, color_black
		jal draw_point
		#Explosion abajo x2
		li t4, 1
		lw t3, count_power
		bne t3, t4, .ph_3
		lw t0, bomb_x
		lw t2, bomb_y
		addi a1,t2,-2
		add a0, zero, t0
		sw a0, explo_x_4, t1
		sw a1, explo_y_4, t1
		lw a2, color_black
		jal draw_point
		.ph_3:
		j .not_count_2
		
		.count_2:
			addi t0, t0, 1
			sw t0, temporizador_2, t1
			
			
		.not_count_2:

		.no_temp_1:
################################################################################################################################
	#Inicia explocion solo cuando la bomba no este activa(iniciar contador)
		lw t0, init_bomb_2
		li t1, 1
		bne t0,t1, .no_temp_2
	tempo_b2:		
		
		lw t0, temporizador_b2
		lw t1, TEMP_LIMIT_2
		bge t1, t0, .count_b2
		
		li t0, 0
		sw t0, temporizador_b2, t1
		lw a0, bomb_x_2 
		lw a1, bomb_y_2
		lw a2, color_black
		jal draw_point
		
		#Colocar solo una bomba
		li t2, 0
     		sw t2, init_bomb_2, t1
     		
		#Explosion a la derecha
		lw t0, bomb_x_2
		lw t2, bomb_y_2
		addi a0,t0,1
		add a1, zero, t2
		sw a0, expb2_x_1, t1
		sw a1, expb2_y_1, t1
		lw a2, color_white
		jal draw_point

		#Compara enemigo 1 con la explosion derecha
		lw t0, enemy_x
		lw t1, enemy_y
		bne a0, t0, .other_1b2
		bne a1, t1, .other_1b2
		li t0, 1
		sw t0, erase_enemy, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		
				
		.other_1b2:
		#Compara enemigo 2 con la explosion derecha
		lw t0, enemy_x_2
		lw t1, enemy_y_2
		bne a0, t0, .other_2b2
		bne a1, t1, .other_2b2
		li t0, 1
		lw t0, erase_enemy_2
		addi t0, t0, 1
		sw t0, erase_enemy_2, t1
		#Contador de puntos
		li t4, 2
		lw t3, erase_enemy_2
		bne t4,t3, .other_2b2
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		
		.other_2b2:
		#Compara enemigo 3 con la explosion derecha
		lw t0, enemy_x_3
		lw t1, enemy_y_3
		bne a0, t0, .other_3b2
		bne a1, t1, .other_3b2
		li t0, 1
		sw t0, erase_enemy_3, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2	
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2

						
		.other_3b2:
		#Compara jugador con la explosion derecha
		lw t0, player_x
		lw t1, player_y
		bne a0, t0, .nothing_3b2
		bne a1, t1, .nothing_3b2
		li t0, 6
		li t1, 5
		sw t0, player_x, t2 
		sw t1, player_y, t2
		
		#Contador de vidas
		li t0, 1
		sw t0,count_lifes, t2
		lw t0, count_lifes_1
		addi t0, t0, 1
		sw t0, count_lifes_1, t2
		lw t1, count_lifes_2
		addi t1, t1, 1
		sw t1, count_lifes_2, t2
		
		.nothing_3b2:
				 
		#Explosion a la izquierda
		lw t0, bomb_x_2
		lw t2, bomb_y_2
		addi a0,t0,-1
		add a1, zero, t2
		sw a0, expb2_x_2, t1
		sw a1, expb2_y_2, t1
		lw a2, color_white
		jal draw_point
		
		#Compara enemigo 1 con la explosion izquierda
		lw t0, enemy_x
		lw t1, enemy_y
		bne a0, t0, .other_4b2
		bne a1, t1, .other_4b2
		li t0, 1
		sw t0, erase_enemy, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		
		.other_4b2:
		#Compara enemigo 2 con la explosion izquierda
		lw t0, enemy_x_2
		lw t1, enemy_y_2
		bne a0, t0, .other_5b2
		bne a1, t1, .other_5b2
		li t0, 1
		lw t0, erase_enemy_2
		addi t0, t0, 1
		sw t0, erase_enemy_2, t1
		#Contador de puntos
		li t4, 2
		lw t3, erase_enemy_2
		bne t4,t3, .other_5b2
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2

		.other_5b2:
		#Compara enemigo 3 con la explosion izquierda
		lw t0, enemy_x_3
		lw t1, enemy_y_3
		bne a0, t0, .other_6b2
		bne a1, t1, .other_6b2
		li t0, 1
		sw t0, erase_enemy_3, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2	
			
		.other_6b2:
		#Compara jugador con la explosion izquierda
		lw t0, player_x
		lw t1, player_y
		bne a0, t0, .nothing_2b2
		bne a1, t1, .nothing_2b2
		li t0, 6
		li t1, 5
		sw t0, player_x, t2 
		sw t1, player_y, t2
		
		#Contador de vidas
		li t0, 1
		sw t0,count_lifes, t2
		lw t0, count_lifes_1
		addi t0, t0, 1
		sw t0, count_lifes_1, t2
		lw t1, count_lifes_2
		addi t1, t1, 1
		sw t1, count_lifes_2, t2
		
		.nothing_2b2:
		#Explosion abajo
		lw t0, bomb_x_2
		lw t2, bomb_y_2
		addi a1,t2, 1
		add a0, zero, t0
		sw a0, expb2_x_3, t1
		sw a1, expb2_y_3, t1
		lw a2, color_white
		jal draw_point
				
		#Compara enemigo 1 con la explosion abajo
		lw t0, enemy_x
		lw t1, enemy_y
		bne a0, t0, .other_7b2
		bne a1, t1, .other_7b2
		li t0, 1
		sw t0, erase_enemy, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
					
		.other_7b2:
		#Compara enemigo 2 con la explosion abajo
		lw t0, enemy_x_2
		lw t1, enemy_y_2
		bne a0, t0, .other_8b2
		bne a1, t1, .other_8b2
		li t0, 1
		lw t0, erase_enemy_2
		addi t0, t0, 1
		sw t0, erase_enemy_2, t1
		#Contador de puntos
		li t4, 2
		lw t3, erase_enemy_2
		bne t4,t3, .other_8b2
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
			
		.other_8b2:
		#Compara enemigo 3 con la explosion abajo
		lw t0, enemy_x_3
		lw t1, enemy_y_3
		bne a0, t0, .other_9b2
		bne a1, t1, .other_9b2
		li t0, 1
		sw t0, erase_enemy_3, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2	
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2

					
		.other_9b2:
		#Compara jugador con la explosion abajo
		lw t0, player_x
		lw t1, player_y
		bne a0, t0, .nothing_1b2
		bne a1, t1, .nothing_1b2
		li t0, 6
		li t1, 5
		sw t0, player_x, t2 
		sw t1, player_y, t2
	
		#Contador de vidas
		li t0, 1
		sw t0,count_lifes, t2
		lw t0, count_lifes_1
		addi t0, t0, 1
		sw t0, count_lifes_1, t2
		lw t1, count_lifes_2
		addi t1, t1, 1
		sw t1, count_lifes_2, t2
		
		.nothing_1b2:
		#Explosion arriba
		lw t0, bomb_x_2
		lw t2, bomb_y_2
		addi a1,t2,-1
		add a0, zero, t0
		sw a0, expb2_x_4, t1
		sw a1, expb2_y_4, t1
		lw a2, color_white
		jal draw_point
				
		#Compara enemigo 1 con la explosion arriba
		lw t0, enemy_x
		lw t1, enemy_y
		bne a0, t0, .other_10b2
		bne a1, t1, .other_10b2
		li t0, 1
		sw t0, erase_enemy, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2	

						
		.other_10b2:
		#Compara enemigo 2 con la explosion arriba
		lw t0, enemy_x_2
		lw t1, enemy_y_2
		bne a0, t0, .other_11b2
		bne a1, t1, .other_11b2
		li t0, 1
		lw t0, erase_enemy_2
		addi t0, t0, 1
		sw t0, erase_enemy_2, t1
		#Contador de puntos
		li t4, 2
		lw t3, erase_enemy_2
		bne t4,t3, .other_11b2
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
			
		.other_11b2:
		#Compara enemigo 3 con la explosion arriba
		lw t0, enemy_x_3
		lw t1, enemy_y_3
		bne a0, t0, .other_12b2
		bne a1, t1, .other_12b2
		li t0, 1
		sw t0, erase_enemy_3, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2

						
		.other_12b2:
		#Compara jugador con la explosion arriba
		lw t0, player_x
		lw t1, player_y
		bne a0, t0, .nothingb2
		bne a1, t1, .nothingb2
		li t0, 6
		li t1, 5
		sw t0, player_x, t2 
		sw t1, player_y, t2
		
		#Contador de vidas
		li t0, 1
		sw t0,count_lifes, t2
		lw t0, count_lifes_1
		addi t0, t0, 1
		sw t0, count_lifes_1, t2
		lw t1, count_lifes_2
		addi t1, t1, 1
		sw t1, count_lifes_2, t2
		
		.nothingb2:
		##########################
		#Explosion a la derecha x2
		li t4, 1
		lw t3, count_power
		bne t3, t4, .pw_18b2
		lw t0, bomb_x_2
		lw t2, bomb_y_2
		addi a0,t0,2
		add a1, zero, t2
		sw a0, explob2_x_1, t1
		sw a1, explob2_y_1, t1
		lw a2, color_white
		jal draw_point

	
		#Compara enemigo 1 con la explosion derecha x2
		lw t0, enemy_x
		lw t1, enemy_y
		bne a0, t0, .pw_1b2
		bne a1, t1, .pw_1b2
		li t0, 1
		sw t0, erase_enemy, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		
				
		.pw_1b2:
		#Compara enemigo 2 con la explosion derecha x2
		lw t0, enemy_x_2
		lw t1, enemy_y_2
		bne a0, t0, .pw_2b2
		bne a1, t1, .pw_2b2
		li t0, 1
		lw t0, erase_enemy_2
		addi t0, t0, 1
		sw t0, erase_enemy_2, t1
		#Contador de puntos
		li t4, 2
		lw t3, erase_enemy_2
		bne t4,t3, .pw_2b2
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
				
		.pw_2b2:
		#Compara enemigo 3 con la explosion derecha x2
		lw t0, enemy_x_3
		lw t1, enemy_y_3
		bne a0, t0, .pw_3b2
		bne a1, t1, .pw_3b2
		li t0, 1
		sw t0, erase_enemy_3, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2	
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2

						
		.pw_3b2:
		#Compara jugador con la explosion derecha x2
		lw t0, player_x
		lw t1, player_y
		bne a0, t0, .pw_4b2
		bne a1, t1, .pw_4b2
		li t0, 6
		li t1, 5
		sw t0, player_x, t2 
		sw t1, player_y, t2
		
		#Contador de vidas
		li t0, 1
		sw t0,count_lifes, t2
		lw t0, count_lifes_1
		addi t0, t0, 1
		sw t0, count_lifes_1, t2
		lw t1, count_lifes_2
		addi t1, t1, 1
		sw t1, count_lifes_2, t2
		
		.pw_4b2:
		############################
                #Explosion a la izquierda x2
                li t4, 1
		lw t3, count_power
		bne t3, t4, .pw_18b2
		lw t0, bomb_x_2
		lw t2, bomb_y_2
		addi a0,t0,-2
		add a1, zero, t2
		sw a0, explob2_x_2, t1
		sw a1, explob2_y_2, t1
		lw a2, color_white
		jal draw_point
		
		#Compara enemigo 1 con la explosion izquierda x2
		lw t0, enemy_x
		lw t1, enemy_y
		bne a0, t0, .pw_5b2
		bne a1, t1, .pw_5b2
		li t0, 1
		sw t0, erase_enemy, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		
		.pw_5b2:
		#Compara enemigo 2 con la explosion izquierda x2
		lw t0, enemy_x_2
		lw t1, enemy_y_2
		bne a0, t0, .pw_6b2
		bne a1, t1, .pw_6b2
		li t0, 1
		lw t0, erase_enemy_2
		addi t0, t0, 1
		sw t0, erase_enemy_2, t1
		#Contador de puntos
		li t4, 2
		lw t3, erase_enemy_2
		bne t4,t3, .pw_6b2
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2

		.pw_6b2:
		#Compara enemigo 3 con la explosion izquierda x2
		lw t0, enemy_x_3
		lw t1, enemy_y_3
		bne a0, t0, .pw_7b2
		bne a1, t1, .pw_7b2
		li t0, 1
		sw t0, erase_enemy_3, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2	
			
		.pw_7b2:
		#Compara jugador con la explosion izquierda x2
		lw t0, player_x
		lw t1, player_y
		bne a0, t0, .pw_8b2
		bne a1, t1, .pw_8b2
		li t0, 6
		li t1, 5
		sw t0, player_x, t2 
		sw t1, player_y, t2
		
		#Contador de vidas
		li t0, 1
		sw t0,count_lifes, t2
		lw t0, count_lifes_1
		addi t0, t0, 1
		sw t0, count_lifes_1, t2
		lw t1, count_lifes_2
		addi t1, t1, 1
		sw t1, count_lifes_2, t2
		
		.pw_8b2:
		#######################		
		#Explosion abajo x2
		li t4, 1
		lw t3, count_power
		bne t3, t4, .pw_18b2
		lw t0, bomb_x_2
		lw t2, bomb_y_2
		addi a1,t2, 2
		add a0, zero, t0
		sw a0, explob2_x_3, t1
		sw a1, explob2_y_3, t1
		lw a2, color_white
		jal draw_point
				
		#Compara enemigo 1 con la explosion abajo x2
		lw t0, enemy_x
		lw t1, enemy_y
		bne a0, t0, .pw_10b2
		bne a1, t1, .pw_10b2
		li t0, 1
		sw t0, erase_enemy, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
					
		.pw_10b2:
		#Compara enemigo 2 con la explosion abajo x2
		lw t0, enemy_x_2
		lw t1, enemy_y_2
		bne a0, t0, .pw_11b2
		bne a1, t1, .pw_11b2
		li t0, 1
		lw t0, erase_enemy_2
		addi t0, t0, 1
		sw t0, erase_enemy_2, t1
		#Contador de puntos
		li t4, 2
		lw t3, erase_enemy_2
		bne t4,t3, .pw_11b2
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
			
		.pw_11b2:
		#Compara enemigo 3 con la explosion abajo x2
		lw t0, enemy_x_3
		lw t1, enemy_y_3
		bne a0, t0, .pw_12b2
		bne a1, t1, .pw_12b2
		li t0, 1
		sw t0, erase_enemy_3, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2	
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2

					
		.pw_12b2:
		#Compara jugador con la explosion abajo x2
		lw t0, player_x
		lw t1, player_y
		bne a0, t0, .pw_13b2
		bne a1, t1, .pw_13b2
		li t0, 6
		li t1, 5
		sw t0, player_x, t2 
		sw t1, player_y, t2
	
		#Contador de vidas
		li t0, 1
		sw t0,count_lifes, t2
		lw t0, count_lifes_1
		addi t0, t0, 1
		sw t0, count_lifes_1, t2
		lw t1, count_lifes_2
		addi t1, t1, 1
		sw t1, count_lifes_2, t2
		
		.pw_13b2:
		#Explosion arriba x2
		li t4, 1
		lw t3, count_power
		bne t3, t4, .pw_18b2
		lw t0, bomb_x_2
		lw t2, bomb_y_2
		addi a1,t2,-2
		add a0, zero, t0
		sw a0, explob2_x_4, t1
		sw a1, explob2_y_4, t1
		lw a2, color_white
		jal draw_point
				
		#Compara enemigo 1 con la explosion arriba x2
		lw t0, enemy_x
		lw t1, enemy_y
		bne a0, t0, .pw_15b2
		bne a1, t1, .pw_15b2
		li t0, 1
		sw t0, erase_enemy, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2	

						
		.pw_15b2:
		#Compara enemigo 2 con la explosion arriba
		lw t0, enemy_x_2
		lw t1, enemy_y_2
		bne a0, t0, .pw_16b2
		bne a1, t1, .pw_16b2
		li t0, 1
		lw t0, erase_enemy_2
		addi t0, t0, 1
		sw t0, erase_enemy_2, t1
		#Contador de puntos
		li t4, 2
		lw t3, erase_enemy_2
		bne t4,t3, .pw_16b2
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
						
		.pw_16b2:
		#Compara enemigo 3 con la explosion arriba
		lw t0, enemy_x_3
		lw t1, enemy_y_3
		bne a0, t0, .pw_17b2
		bne a1, t1, .pw_17b2
		li t0, 1
		sw t0, erase_enemy_3, t1
		#Contador de muertes de enemigos
		lw t0, count_portal
		addi t0, t0, 1
		sw t0, count_portal, t2
		#Contador de puntos
		li t3, 1
		lw t3, count_score
		addi t3, t3, 1
		sw t3, count_score, t2
						
		.pw_17b2:
		#Compara jugador con la explosion arriba
		lw t0, player_x
		lw t1, player_y
		bne a0, t0, .pw_18b2
		bne a1, t1, .pw_18b2
		li t0, 6
		li t1, 5
		sw t0, player_x, t2 
		sw t1, player_y, t2
		
		#Contador de vidas
		li t0, 1
		sw t0,count_lifes, t2
		lw t0, count_lifes_1
		addi t0, t0, 1
		sw t0, count_lifes_1, t2
		lw t1, count_lifes_2
		addi t1, t1, 1
		sw t1, count_lifes_2, t2
		
		.pw_18b2:		
		j .not_count_b2
		
		.count_b2:
			addi t0, t0, 1
			sw t0, temporizador_b2, t1
			lw a0, bomb_x_2 
			lw a1, bomb_y_2
			lw a2, color_cyan
			jal draw_point
		.not_count_b2:
		
		.no_temp_2:
		
	lw t0, init_bomb_2
	li t1, 0
	bne t0,t1, .no_temp_1b2
	
	tempo_2b2:
	
	        #Borra la explocion
		lw t0, temporizador_2b2
		lw t1, TEMP_LIMIT_2
		bge t1, t0, .count_2b2
		li t0, 0
		sw t0, temporizador_2b2, t1
		
		#Explosion a la derecha
		lw t0, bomb_x_2
		lw t2, bomb_y_2
		addi a0,t0,1
		add a1, zero, t2
		sw a0, expb2_x_1, t1
		sw a1, expb2_y_1, t1
		lw a2, color_black
		jal draw_point
		
		#Explosion a la derecha x2
		li t4, 1
		lw t3, count_power
		bne t3, t4, .phb2
		lw t0, bomb_x_2
		lw t2, bomb_y_2
		addi a0,t0,2
		add a1, zero, t2
		sw a0, explob2_x_1, t1
		sw a1, explob2_y_1, t1
		lw a2, color_black
		jal draw_point
		.phb2:
		#Explosion a la izquierda
		lw t0, bomb_x_2
		lw t2, bomb_y_2
		addi a0,t0,-1
		add a1, zero, t2
		sw a0, expb2_x_2, t1
		sw a1, expb2_y_2, t1
		lw a2, color_black
		jal draw_point
		#Explosion a la izquierda x2
		li t4, 1
		lw t3, count_power
		bne t3, t4, .ph_1b2
		lw t0, bomb_x_2
		lw t2, bomb_y_2
		addi a0,t0,-2
		add a1, zero, t2
		sw a0, explob2_x_2, t1
		sw a1, explob2_y_2, t1
		lw a2, color_black
		jal draw_point
		.ph_1b2:
		#Explosion arriba
		lw t0, bomb_x_2
		lw t2, bomb_y_2
		addi a1,t2, 1
		add a0, zero, t0
		sw a0, expb2_x_3, t1
		sw a1, expb2_y_3, t1
		lw a2, color_black
		jal draw_point
		#Explosion arriba x2
		li t4, 1
		lw t3, count_power
		bne t3, t4, .ph_2b2
		lw t0, bomb_x_2
		lw t2, bomb_y_2
		addi a1,t2, 2
		add a0, zero, t0
		sw a0, explob2_x_3, t1
		sw a1, explob2_y_3, t1
		lw a2, color_black
		jal draw_point
		.ph_2b2:
		#Explosion abajo
		lw t0, bomb_x_2
		lw t2, bomb_y_2
		addi a1,t2,-1
		add a0, zero, t0
		sw a0, expb2_x_4, t1
		sw a1, expb2_y_4, t1
		lw a2, color_black
		jal draw_point
		#Explosion abajo x2
		li t4, 1
		lw t3, count_power
		bne t3, t4, .ph_3b2
		lw t0, bomb_x_2
		lw t2, bomb_y_2
		addi a1,t2,-2
		add a0, zero, t0
		sw a0, explob2_x_4, t1
		sw a1, explob2_y_4, t1
		lw a2, color_black
		jal draw_point
		.ph_3b2:
		j .not_count_2b2
		
		.count_2b2:
			addi t0, t0, 1
			sw t0, temporizador_2b2, t1
			
			
		.not_count_2b2:

		.no_temp_1b2:
		
		#Contador de colision de jugador enemigo
		lw t0, enemy_x
		lw t1, enemy_y
		lw t2, player_x
		lw t3, player_y
		bne t0, t2, .de
		bne t1, t3, .de
		#Contador de vidas
		li t0, 1
		sw t0,count_lifes, t2
		lw t0, count_lifes_1
		addi t0, t0, 1
		sw t0, count_lifes_1, t2
		lw t1, count_lifes_2
		addi t1, t1, 1
		sw t1, count_lifes_2, t2
		
		.de:
		#Contador de colision de jugador enemigo
		lw t0, enemy_x_2
		lw t1, enemy_y_2
		lw t2, player_x
		lw t3, player_y
		bne t0, t2, .du
		bne t1, t3, .du
		#Contador de vidas
		li t0, 1
		sw t0,count_lifes, t2
		lw t0, count_lifes_1
		addi t0, t0, 1
		sw t0, count_lifes_1, t2
		lw t1, count_lifes_2
		addi t1, t1, 1
		sw t1, count_lifes_2, t2
		
		.du:
		#Contador de colision de jugador enemigo
		lw t0, enemy_x_3
		lw t1, enemy_y_3
		lw t2, player_x
		lw t3, player_y
		bne t0, t2, .die
		bne t1, t3, .die
		#Contador de vidas
		li t0, 1
		sw t0,count_lifes, t2
		lw t0, count_lifes_1
		addi t0, t0, 1
		sw t0, count_lifes_1, t2
		lw t1, count_lifes_2
		addi t1, t1, 1
		sw t1, count_lifes_2, t2
		
		.die:
		
		jal draw_solid_blocks
	        jal draw_walls
	        jal draw_lifes
   		jal draw_enemies
		jal draw_enemies_2
		jal draw_enemies_3
		jal draw_portal
		jal draw_score_1
		jal draw_power
		jal draw_power_2
		jal draw_power_3
		
		lw a0, player_x
		lw a1, player_y
		lw a2, color_red
		mv a3, s0
		jal draw_player
		sw a0, player_x, t0 
		sw a1, player_y, t0
		li s0, MOV_STAY
		
		#Reafirmar color red
	        lw a2, color_red
	        jal draw_point
	        
# Wait and read inputs
	.begin_standby:
		li t0, 2 # A counter is loaded for an aprox 50ms delay
	
	.standby:
		blez t0, .end_standby
		
		# syscall for pausing 10 ms
		li a0, 10
		li a7, 32
		ecall		
	
		addi t0, t0, -1
		
		# check for a key press
		lw t1, KEY_STATUS_ADDRESS
		blez t1, .standby
		
		jal adjust_dir
		sw zero, KEY_STATUS_ADDRESS, t1 # Clean the state that a key has been pressed
		#j .standby
		
	.end_standby:
		j .draw_objects
		
###############################################################################################################################
		
# Function: adjust_dir
# Parameters:
#	None.
# Return:
#	void.

adjust_dir:
	lw t0, KEY_INPUT_ADDRESS
	
	.adjust_dir_left_up:
		li t1, ASCII_W
		bne t0, t1, .adjust_dir_left_down
		li s0, MOV_UP
		j .adjust_dir_done
	
	.adjust_dir_left_down:
		li t1, ASCII_S
		bne t0, t1, .adjust_dir_left_left
		li s0, MOV_DOWN
		j .adjust_dir_done
	
	.adjust_dir_left_left:
		li t1, ASCII_A
		bne t0, t1, .adjust_dir_left_right
		li s0, MOV_LEFT
		j .adjust_dir_done
		
	.adjust_dir_left_right:
		li t1, ASCII_D
		bne t0, t1, .adjust_dir_bomb
		li s0, MOV_RIGHT
		j .adjust_dir_done
	
	.adjust_dir_bomb:
		li t1, ASCII_B
		bne t0, t1, .adjust_dir_bomb_2
		li s0, bomb
		j .adjust_dir_done
		
	.adjust_dir_bomb_2:
		li t1, ASCII_N
		bne t0, t1, .adjust_dir_none
		li s0, bomb_2
		j .adjust_dir_done
		
	.adjust_dir_none:
		# This section is kept as a case point if the player didn't press a valid option
	    
	.adjust_dir_done:
		jr ra
		
##############################################################################################################################
draw_score_1:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	lw t2, count_score
	li t4, 1
	bne t2, t4, .other_score
	lw a2, color_white
	li a0, 58
	li a1, 0
	jal draw_point

	.other_score:
	li t3, 1
	lw t1,count_level
	bne t3, t1, .col
	lw a2, color_white
	li a0, 58
	li a1, 0
	jal draw_point
	
	lw a2, color_white
	li a0, 56
	li a1, 0
	jal draw_point
	
	.col:
	lw t2, count_score
	li t4, 2
	bne t2, t4, .other_score_1
	
	lw a2, color_white
	li a0, 56
	li a1, 0
	jal draw_point
	
	.other_score_1:

	lw t2, count_score
	li t4, 3
	bne t2, t4, .other_score_2
	
	lw a2, color_white
	li a0, 54
	li a1, 0
	jal draw_point
	
	.other_score_2:
	li t3, 1
	lw t1,count_level_1
	bne t3, t1, .col_1
	lw a2, color_white
	li a0, 54
	li a1, 0
	jal draw_point
	
	lw a2, color_white
	li a0, 52
	li a1, 0
	jal draw_point
	
	lw a2, color_white
	li a0, 50
	li a1, 0
	jal draw_point
	
	.col_1:	
	lw t2, count_score
	li t4, 4
	bne t2, t4, .other_score_3
	
	lw a2, color_white
	li a0, 52
	li a1, 0
	jal draw_point
	
	.other_score_3:
	
	lw t2, count_score
	li t4, 5
	bne t2, t4, .other_score_4
	
	lw a2, color_white
	li a0, 50
	li a1, 0
	jal draw_point
	
	.other_score_4:
	
	lw t2, count_score
	li t4, 6
	bne t2, t4, .other_score_5
	
	lw a2, color_white
	li a0, 48
	li a1, 0
	jal draw_point
	
	.other_score_5:
	lw t2, count_score
	li t4, 7
	bne t2, t4, .other_score_6
	
	lw a2, color_white
	li a0, 46
	li a1, 0
	jal draw_point
	
	.other_score_6:
	
	lw t2, count_score
	li t4, 8
	bne t2, t4, .other_score_7
	
	lw a2, color_white
	li a0, 44
	li a1, 0
	jal draw_point
	
	.other_score_7:
	
	lw t2, count_score
	li t4, 9
	bne t2, t4, .other_score_8
	
	lw a2, color_white
	li a0, 42
	li a1, 0
	jal draw_point
	
	.other_score_8:
		
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra
    
##############################################################################################################################
draw_power:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	lw a2, color_purple
	lw a0, power_1_x
	lw a1, power_1_y
	jal draw_point
	
	lw t0, power_1_x
	lw t1, power_1_y
	lw a0, player_x
	lw a1, player_y
	bne t0, a0, .pir
	bne t1, a1, .pir
	
	li t2, 200
	li t3, 200
	sw t2, power_1_x, t1
	sw t3, power_1_y, t1
	
	li t3, 1
	sw t3, count_power, t2
	
	
	.pir:
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra
##############################################################################################################################
draw_power_2:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	lw a2, color_burdeos
	lw a0, power_2_x
	lw a1, power_2_y
	jal draw_point
	
	lw t0, power_2_x
	lw t1, power_2_y
	lw a0, player_x
	lw a1, player_y
	bne t0, a0, .pup
	bne t1, a1, .pup
	
	li t2, 200
	li t3, 200
	sw t2, power_2_x, t1
	sw t3, power_2_y, t1
	
	li t3, 1
	sw t3, count_bomb, t2
	
	.pup:
	
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra
##############################################################################################################################
draw_power_3:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	lw a2, color_rosybrown
	lw a0, power_3_x
	lw a1, power_3_y
	jal draw_point
	
	lw t0, power_3_x
	lw t1, power_3_y
	lw a0, player_x
	lw a1, player_y
	bne t0, a0, .pup
	bne t1, a1, .pup
	
	li t2, 200
	li t3, 200
	sw t2, power_3_x, t1
	sw t3, power_3_y, t1
	
	li t3, 1
	sw t3, Patin_count, t2
	
	.pup_1:
	
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra
##############################################################################################################################
draw_portal:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	lw a2, color_pink
	li a0, 4
	li a1, 6
	jal draw_point
	
	li t3, 1
	lw t5, level_1_load
	lw t2, count_portal
	li t4, 3
	bne t3, t5, .oth
	bne t2, t4, .oth
	
	li t0, 4
	li t1, 6
	lw a0, player_x
	lw a1, player_y
	bne t0, a0, .pi
	bne t1, a1, .pi
	jal clear_board
	j draw_level_2
	 
	.pi:

	.oth:
	li t0, 1
	lw t5, level_2_load
	lw t2, count_portal
	li t4, 3
	bne t5, t0, .oth_1
	bne t2, t4, .oth_1
	
	li t0, 4
	li t1, 6
	lw a0, player_x
	lw a1, player_y
	bne t0, a0, .pi_1
	bne t1, a1, .pi_1
	jal clear_board
	j draw_level_3
	 
	.pi_1:
	
	.oth_1:
	li t0, 1
	lw t5, level_3_load
	lw t2, count_portal
	li t4, 3
	bne t2, t4, .oth_2
	bne t5, t0, .oth_2
	
	li t0, 4
	li t1, 6
	lw a0, player_x
	lw a1, player_y
	bne t0, a0, .pi_2
	bne t1, a1, .pi_2
	jal clear_board
	j draw_win 
	
	.pi_2:
	
	.oth_2:
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra

##############################################################################################################################	
draw_lifes:

	addi sp, sp, -4
	sw ra, 0(sp)

	lw a2, color_red
	li a0, 9
	li a1, 0
	jal draw_point
	
	lw t1, count_lifes
	li t0, 1
	bne t0, t1, .jump
	
	lw a2, color_black
	li a0, 9
	li a1, 0
	jal draw_point
	
	.jump:
	
	lw a2, color_red
	li a0, 7
	li a1, 0
	jal draw_point
	
	lw t1, count_lifes_1
	li t0, 2
	bne t0, t1, .jump_1
	
	lw a2, color_black
	li a0, 7
	li a1, 0
	jal draw_point
	
	.jump_1:
	
	lw a2, color_red
	li a0, 5
	li a1, 0
	jal draw_point
	
	lw t1, count_lifes_2
	li t0, 3
	bne t0, t1, .jump_2
	
	lw a2, color_black
	li a0, 5
	li a1, 0
	jal draw_point
	
	jal clear_board
	j draw_game_over

	.jump_2:
	
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra


####################################################################################################################3	
play_point_sound:
	# Plays a sound when a player scores
	li a0, 80
	li a1, 300
	li a2, 121
	li a3, 127
	li a7, 31
	ecall
	j Level_1
###############################################################################################################################	
draw_win:

	addi sp, sp, -4
	sw ra, 0(sp)

	# The upper lines
	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	lw a2, color_blue
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	addi a1, a1, 1
	lw a2, color_white
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	addi a1, a1, 2
	lw a2, color_red
	li a3, 63
	jal draw_horizontal_line
	
	# The below lines
	li a0, 0
	li a1, TITLE_SCREEN_SECOND_LINE_ROW_Y
	lw a2, color_red
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_SECOND_LINE_ROW_Y
	addi a1, a1, 1
	lw a2, color_white
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_SECOND_LINE_ROW_Y
	addi a1, a1, 2
	lw a2, color_blue
	li a3, 63
	jal draw_horizontal_line
	
	#Win text
	# The W
		li a0, WINS_TEXT_X
		li a1, WINS_TEXT_Y
		lw a2, color_white
		addi a3, a1, 2
		jal draw_vertical_line
		
		li a0, WINS_TEXT_X
		addi a0, a0, 1
		li a1, WINS_TEXT_Y
		addi a1, a1, 3
		lw a2, color_white
		addi a3, a1, 1
		jal draw_vertical_line
		
		li a0, WINS_TEXT_X
		addi a0, a0, 2
		li a1, WINS_TEXT_Y
		addi a1, a1, WINS_TEXT_H
		lw a2, color_white
		jal draw_point
		
		li a0, WINS_TEXT_X
		addi a0, a0, 3
		li a1, WINS_TEXT_Y
		addi a1, a1, 3
		lw a2, color_white
		addi a3, a1, 1
		jal draw_vertical_line
		
		li a0, WINS_TEXT_X
		addi a0, a0, 4
		li a1, WINS_TEXT_Y
		addi a1, a1, WINS_TEXT_H
		lw a2, color_white
		jal draw_point
		
		li a0, WINS_TEXT_X
		addi a0, a0, 5
		li a1, WINS_TEXT_Y
		addi a1, a1, 3
		lw a2, color_white
		addi a3, a1, 1
		jal draw_vertical_line
		
		li a0, WINS_TEXT_X
		addi a0, a0, 6
		li a1, WINS_TEXT_Y
		lw a2, color_white
		addi a3, a1, 2
		jal draw_vertical_line
		
	# The I starts at offset 8
.eqv I_OFFSET 8
		li a0, WINS_TEXT_X
		addi a0, a0, I_OFFSET
		li a1, WINS_TEXT_Y
		lw a2, color_white
		addi a3, a0, 4 
		jal draw_horizontal_line
		
		li a0, WINS_TEXT_X
		addi a0, a0, I_OFFSET
		addi a0, a0, 2
		li a1, WINS_TEXT_Y
		lw a2, color_white
		addi a3, a1, WINS_TEXT_H
		jal draw_vertical_line
		
		li a0, WINS_TEXT_X
		addi a0, a0, I_OFFSET
		li a1, WINS_TEXT_Y
		addi a1, a1, WINS_TEXT_H
		lw a2, color_white
		addi a3, a0, 4 
		jal draw_horizontal_line
	
		# The N starts at offset 14
.eqv N_OFFSET 14

		li a0, WINS_TEXT_X
		addi a0, a0, N_OFFSET
		li a1, WINS_TEXT_Y
		lw a2, color_white
		addi a3, a1, WINS_TEXT_H
		jal draw_vertical_line
		
		li a0, WINS_TEXT_X
		addi a0, a0, N_OFFSET
		addi a0, a0, 1
		li a1, WINS_TEXT_Y
		lw a2, color_white
		addi a3, a1, 1
		jal draw_vertical_line
		
		li a0, WINS_TEXT_X
		addi a0, a0, N_OFFSET
		addi a0, a0, 2
		li a1, WINS_TEXT_Y
		addi a1, a1, 2
		lw a2, color_white
		addi a3, a1, 1
		jal draw_vertical_line
		
		li a0, WINS_TEXT_X
		addi a0, a0, N_OFFSET
		addi a0, a0, 3
		li a1, WINS_TEXT_Y
		addi a1, a1, 4
		lw a2, color_white
		addi a3, a1, 1
		jal draw_vertical_line

		li a0, WINS_TEXT_X
		addi a0, a0, N_OFFSET
		addi a0, a0, 4
		li a1, WINS_TEXT_Y
		lw a2, color_white
		addi a3, a1, WINS_TEXT_H
		jal draw_vertical_line
		
		#The S starts at offset 20
.eqv S_OFFSET 20
		li a0, WINS_TEXT_X
		addi a0, a0, S_OFFSET
		li a1, WINS_TEXT_Y
		lw a2, color_white
		addi a3, a0, 4
		jal draw_horizontal_line
		
		li a0, WINS_TEXT_X
		addi a0, a0, S_OFFSET
		li a1, WINS_TEXT_Y
		lw a2, color_white
		addi a3, a1, 1
		jal draw_vertical_line
		
		li a0, WINS_TEXT_X
		addi a0, a0, S_OFFSET
		li a1, WINS_TEXT_Y
		addi a1, a1, 2
		lw a2, color_white
		addi a3, a0, 2
		jal draw_horizontal_line
		
		li a0, WINS_TEXT_X
		addi a0, a0, S_OFFSET
		addi a0, a0, 2
		li a1, WINS_TEXT_Y
		addi a1, a1, 3
		lw a2, color_white
		addi a3, a0, 1
		jal draw_horizontal_line
		
		li a0, WINS_TEXT_X
		addi a0, a0, S_OFFSET
		addi a0, a0, 4
		li a1, WINS_TEXT_Y
		addi a1, a1, 3
		lw a2, color_white
		addi a3, a1, 2
		jal draw_vertical_line
		
		li a0, WINS_TEXT_X
		addi a0, a0, S_OFFSET
		li a1, WINS_TEXT_Y
		addi a1, a1, WINS_TEXT_H
		lw a2, color_white
		addi a3, a0, 4
		jal draw_horizontal_line

	.pause:
		li a0, 3000
		li a7, 32	
		ecall		#Pause for 100 milisec
		
	jal clear_key_status
	
	.reset_wait:
		li a0, 10
		li a7, 32 
		ecall		#Pause for 100 milisec
		
		li t0, KEY_STATUS_ADDRESS
		beq t0, zero, .reset_wait
		
		j .reset
	
	.reset:
		sw zero, p1_score, t0
		sw zero, p2_score, t0
		jal clear_key_status
		jal clear_key_press
		
		jal clear_board
		
		j new_game
	lw ra, 0(sp)
	addi sp, sp, 4
	
	jr ra
###############################################################################################################################	
draw_level_2:

	addi sp, sp, -4
	sw ra, 0(sp)

	# The upper lines
	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	lw a2, color_blue
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	addi a1, a1, 1
	lw a2, color_white
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	addi a1, a1, 2
	lw a2, color_red
	li a3, 63
	jal draw_horizontal_line
	
	# The below lines
	li a0, 0
	li a1, TITLE_SCREEN_SECOND_LINE_ROW_Y
	lw a2, color_red
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_SECOND_LINE_ROW_Y
	addi a1, a1, 1
	lw a2, color_white
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_SECOND_LINE_ROW_Y
	addi a1, a1, 2
	lw a2, color_blue
	li a3, 63
	jal draw_horizontal_line
	
	#Level 1 text
	
	#The L
		
	li a0, PONG_TEXT_X
	addi a0, a0, 12
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 7
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 12
	li a1, PONG_TEXT_Y
	addi a1, a1, 13
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	#The E
	li a0, PONG_TEXT_X
	addi a0, a0, 16
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 7
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 16
	li a1, PONG_TEXT_Y
	addi a1, a1, 10
	lw a2, color_white
	addi a3, a0, 1
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 16
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 16
	li a1, PONG_TEXT_Y
	addi a1, a1, 13
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	#The V
	li a0, PONG_TEXT_X
	addi a0, a0, 20
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 5
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 22
	li a1, PONG_TEXT_Y
	addi a1, a1, 12
	lw a2, color_white
	addi a3, a3, 11
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 23
	li a1, PONG_TEXT_Y
	addi a1, a1, 13
	lw a2, color_white
	addi a3, a3, 1
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 24
	li a1, PONG_TEXT_Y
	addi a1, a1, 12
	lw a2, color_white
	addi a3, a3, 1
	jal draw_horizontal_line

	li a0, PONG_TEXT_X
	addi a0, a0, 24
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 5
	jal draw_vertical_line
	
	#The E
	li a0, PONG_TEXT_X
	addi a0, a0, 26
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 7
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 26
	li a1, PONG_TEXT_Y
	addi a1, a1, 10
	lw a2, color_white
	addi a3, a0, 1
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 26
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 26
	li a1, PONG_TEXT_Y
	addi a1, a1, 13
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	#The L
	
	li a0, PONG_TEXT_X
	addi a0, a0, 30
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 7
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 30
	li a1, PONG_TEXT_Y
	addi a1, a1, 13
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	#The 2

	li a0, PONG_TEXT_X
	addi a0, a0, 36
	li a1, PONG_TEXT_Y
	addi a1, a1, 8
	lw a2, color_white
	jal draw_point

	li a0, PONG_TEXT_X
	addi a0, a0, 37
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line	
	
	li a0, PONG_TEXT_X
	addi a0, a0, 40
	li a1, PONG_TEXT_Y
	addi a1, a1, 8
	lw a2, color_white
	jal draw_point
	
	li a0, PONG_TEXT_X
	addi a0, a0, 40
	li a1, PONG_TEXT_Y
	addi a1, a1, 9
	lw a2, color_white
	jal draw_point

	li a0, PONG_TEXT_X
	addi a0, a0, 39
	li a1, PONG_TEXT_Y
	addi a1, a1, 10
	lw a2, color_white
	jal draw_point
	
	li a0, PONG_TEXT_X
	addi a0, a0, 38
	li a1, PONG_TEXT_Y
	addi a1, a1, 11
	lw a2, color_white
	jal draw_point

	li a0, PONG_TEXT_X
	addi a0, a0, 37
	li a1, PONG_TEXT_Y
	addi a1, a1, 12
	lw a2, color_white
	jal draw_point

	li a0, PONG_TEXT_X
	addi a0, a0, 36
	li a1, PONG_TEXT_Y
	addi a1, a1, 13
	lw a2, color_white
	addi a3, a0, 4
	jal draw_horizontal_line
	

	
	.pause_1:
		li a0, 3000
		li a7, 32	
		ecall		#Pause for 100 milisec
		
	jal clear_key_status
	
	.reset_wait_1:
		li a0, 10
		li a7, 32 
		ecall		#Pause for 100 milisec
		
		li t0, KEY_STATUS_ADDRESS
		beq t0, zero, .reset_wait_1
		
		j .reset_1
	
	.reset_1:
		sw zero, p1_score, t0
		sw zero, p2_score, t0
		jal clear_key_status
		jal clear_key_press

		jal clear_board
		
		
		j Level_2
	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra 
###############################################################################################################################	
draw_level_3:

	addi sp, sp, -4
	sw ra, 0(sp)

	# The upper lines
	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	lw a2, color_blue
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	addi a1, a1, 1
	lw a2, color_white
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	addi a1, a1, 2
	lw a2, color_red
	li a3, 63
	jal draw_horizontal_line
	
	# The below lines
	li a0, 0
	li a1, TITLE_SCREEN_SECOND_LINE_ROW_Y
	lw a2, color_red
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_SECOND_LINE_ROW_Y
	addi a1, a1, 1
	lw a2, color_white
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_SECOND_LINE_ROW_Y
	addi a1, a1, 2
	lw a2, color_blue
	li a3, 63
	jal draw_horizontal_line
	
	#Level 1 text
	
	#The L
		
	li a0, PONG_TEXT_X
	addi a0, a0, 12
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 7
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 12
	li a1, PONG_TEXT_Y
	addi a1, a1, 13
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	#The E
	li a0, PONG_TEXT_X
	addi a0, a0, 16
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 7
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 16
	li a1, PONG_TEXT_Y
	addi a1, a1, 10
	lw a2, color_white
	addi a3, a0, 1
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 16
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 16
	li a1, PONG_TEXT_Y
	addi a1, a1, 13
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	#The V
	li a0, PONG_TEXT_X
	addi a0, a0, 20
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 5
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 22
	li a1, PONG_TEXT_Y
	addi a1, a1, 12
	lw a2, color_white
	addi a3, a3, 11
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 23
	li a1, PONG_TEXT_Y
	addi a1, a1, 13
	lw a2, color_white
	addi a3, a3, 1
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 24
	li a1, PONG_TEXT_Y
	addi a1, a1, 12
	lw a2, color_white
	addi a3, a3, 1
	jal draw_horizontal_line

	li a0, PONG_TEXT_X
	addi a0, a0, 24
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 5
	jal draw_vertical_line
	
	#The E
	li a0, PONG_TEXT_X
	addi a0, a0, 26
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 7
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 26
	li a1, PONG_TEXT_Y
	addi a1, a1, 10
	lw a2, color_white
	addi a3, a0, 1
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 26
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 26
	li a1, PONG_TEXT_Y
	addi a1, a1, 13
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	#The L
	
	li a0, PONG_TEXT_X
	addi a0, a0, 30
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 7
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 30
	li a1, PONG_TEXT_Y
	addi a1, a1, 13
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	#The 2

	li a0, PONG_TEXT_X
	addi a0, a0, 36
	li a1, PONG_TEXT_Y
	addi a1, a1, 8
	lw a2, color_white
	jal draw_point

	li a0, PONG_TEXT_X
	addi a0, a0, 37
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line	
	
	li a0, PONG_TEXT_X
	addi a0, a0, 40
	li a1, PONG_TEXT_Y
	addi a1, a1, 8
	lw a2, color_white
	jal draw_point
	
	li a0, PONG_TEXT_X
	addi a0, a0, 40
	li a1, PONG_TEXT_Y
	addi a1, a1, 9
	lw a2, color_white
	jal draw_point

	li a0, PONG_TEXT_X
	addi a0, a0, 39
	li a1, PONG_TEXT_Y
	addi a1, a1, 10
	lw a2, color_white
	jal draw_point
	
	li a0, PONG_TEXT_X
	addi a0, a0, 38
	li a1, PONG_TEXT_Y
	addi a1, a1, 10
	lw a2, color_white
	jal draw_point
	
	li a0, PONG_TEXT_X
	addi a0, a0, 40
	li a1, PONG_TEXT_Y
	addi a1, a1, 11
	lw a2, color_white
	jal draw_point
	
	li a0, PONG_TEXT_X
	addi a0, a0, 40
	li a1, PONG_TEXT_Y
	addi a1, a1, 12
	lw a2, color_white
	jal draw_point
	
	li a0, PONG_TEXT_X
	addi a0, a0, 36
	li a1, PONG_TEXT_Y
	addi a1, a1, 12
	lw a2, color_white
	jal draw_point

	li a0, PONG_TEXT_X
	addi a0, a0, 37
	li a1, PONG_TEXT_Y
	addi a1, a1, 13
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line

	

	.pause_3:
		li a0, 3000
		li a7, 32	
		ecall		#Pause for 100 milisec
		
	jal clear_key_status
	
	.reset_wait_3:
		li a0, 10
		li a7, 32 
		ecall		#Pause for 100 milisec
		
		li t0, KEY_STATUS_ADDRESS
		beq t0, zero, .reset_wait_3
		
		j .reset_3
	
	.reset_3:
		sw zero, p1_score, t0
		sw zero, p2_score, t0
		jal clear_key_status
		jal clear_key_press
		
		jal clear_board
	
		j Level_3
		
	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra 
		
    	
#######################################################################################################
draw_enemies:

	addi sp, sp, -4
	sw ra, 0(sp)
	
	lw t0, exp_x_1
	lw t4, exp_y_1
	
	#Dibuja
	lw a0, enemy_x
	lw a1, enemy_y
	lw a2, color_orange
	jal draw_point
	
	#Verifica si la posicion del jugador coincide con el enemigo
	lw t0, player_x
	lw t2, player_y
	bne a0, t0, .do
	bne a1, t2, .do
	li t0, 6
	li t2, 5
	sw t0, player_x, t1
	sw t2, player_y, t1 
	lw t3, color_white
	jal draw_point
	.do:	

	#Si erase_enemy es un 1, lo manda a volar
	lw t2, erase_enemy
	li t3, 1
	bne t2, t3, .kill_enemy
	li a0, 200
	li a1, 200
	sw a1, enemy_y, t1
	sw a0, enemy_x, t1

	.kill_enemy:
	
	#Genera el random
	lw a0, random_seed
	rdtime a1
	xor a1, a1, a0
    	li a2, 90
    	remu a0, a1, a2
    	add a3, zero, a0

	
            # Ajusta la dirección basada en el número aleatorio
    	    addi t0,zero, MOV_STAY 
    	    beq a3, t0, .no_move
    	    
    	    addi t0,zero,  MOV_UP
   	    beq a3, t0, .move_up 
   	    
    	    addi t0,zero, MOV_DOWN
    	    beq a3, t0, .move_down
    	    
   	    addi t0, zero, MOV_RIGHT
    	    beq a3, t0, .move_right
    	    
    	    addi t0, zero, MOV_LEFT
    	    beq a3, t0, .move_left
	    j .no_move
	    
	.move_up:
	    lw a0, enemy_x
	    lw a1, enemy_y
	    lw a2, color_black
	    jal draw_point
	    addi a1, a1, -1
	    
	    #collision
	    jal draw_black
	    lw a4, color_black
	    bne a4, a2, .move_up_red
	    
	    sw a0, enemy_x, t1
	    sw a1, enemy_y, t1
	    lw a2, color_orange
	    jal draw_point
	    j .no_move
	#Colision del enemigo con el player    
	.move_up_red:
	    lw a0, enemy_x
	    lw a1, enemy_y
	    lw a2, color_black
	    jal draw_point
	    addi a1, a1, -1
	    
	    #collision
	    jal draw_black
	    lw a4, color_red
	    bne a4, a2, .no_move
	    
	    sw a0, enemy_x, t1
	    sw a1, enemy_y, t1
	    lw a2, color_orange
	    jal draw_point
	    j .no_move
	
	.move_down:
	    lw a0, enemy_x
	    lw a1, enemy_y
	    lw a2, color_black
	    jal draw_point
	    addi a1, a1, 1
	    
	    #collision
	    jal draw_black
	    lw a4, color_black
	    bne a4, a2, .move_down_red 
	      
    	    sw a0, enemy_x, t1
	    sw a1, enemy_y, t1
	    lw a2, color_orange
	    jal draw_point
	    j .no_move
	#Colision del enemigo con el player       
	.move_down_red:
	    lw a0, enemy_x
	    lw a1, enemy_y
	    lw a2, color_black
	    jal draw_point
	    addi a1, a1, 1
	    
	    #collision
	    jal draw_black
	    lw a4, color_red
	    bne a4, a2, .no_move 
	      
    	    sw a0, enemy_x, t1
	    sw a1, enemy_y, t1
	    lw a2, color_orange
	    jal draw_point
	    j .no_move	
	        
	.move_right:
	    lw a0, enemy_x
	    lw a1, enemy_y
	    lw a2, color_black
	    jal draw_point
	    addi a0, a0, 1
	    
	    #collision
	    jal draw_black
	    lw a4, color_black
	    bne a4, a2, .move_right_red
	    	    
    	    sw a0, enemy_x, t1
	    sw a1, enemy_y, t1
	    lw a2, color_orange
	    jal draw_point
	    j .no_move
	#Colision del enemigo con el player        
	.move_right_red:
	    lw a0, enemy_x
	    lw a1, enemy_y
	    lw a2, color_black
	    jal draw_point
	    addi a0, a0, 1
	    
	    #collision
	    jal draw_black
	    lw a4, color_red
	    bne a4, a2, .no_move
	    	    
    	    sw a0, enemy_x, t1
	    sw a1, enemy_y, t1
	    lw a2, color_orange
	    jal draw_point
	    j .no_move	    
	.move_left:
	    lw a0, enemy_x
	    lw a1, enemy_y
	    lw a2, color_black
	    jal draw_point
	    addi a0, a0, -1
	    
	    #collision
	    jal draw_black
	    lw a4, color_black
	    bne a4, a2, .move_left_red
	    	    
	    sw a0, enemy_x, t1
	    sw a1, enemy_y, t1
	    lw a2, color_orange
	    jal draw_point
	    j .no_move
	#Colision del enemigo con el player        
	.move_left_red:
	    lw a0, enemy_x
	    lw a1, enemy_y
	    lw a2, color_black
	    jal draw_point
	    addi a0, a0, -1
	    
	    #collision
	    jal draw_black
	    lw a4, color_red
	    bne a4, a2, .no_move
	    	    
	    sw a0, enemy_x, t1
	    sw a1, enemy_y, t1
	    lw a2, color_orange
	    jal draw_point
	    j .no_move	
	.no_move:
	    lw a0, enemy_x
	    lw a1, enemy_y
	    sw a0, enemy_x, t1
	    sw a1, enemy_y, t1
	
	    
	lw ra, 0(sp)
	addi sp, sp, 4
    	jr ra
	

#########################################################################################################
draw_enemies_2:

	addi sp, sp, -4
	sw ra, 0(sp)
	
	#Dibuja
	lw a0, enemy_x_2
	lw a1, enemy_y_2
	lw a2, color_yellow
	jal draw_point
	
	#Verifica si la posicion del jugador coincide con el enemigo
	lw t0, player_x
	lw t2, player_y
	bne a0, t0, .di
	bne a1, t2, .di
	li t0, 6
	li t2, 5
	sw t0, player_x, t1
	sw t2, player_y, t1 
	
	.di:
	
	#Si erase_enemy es un 1, lo manda a volar
	lw t2, erase_enemy_2
	li t3, 2
	bne t2, t3, .kill_enemy_2
	li a0, 200
	li a1, 200
	sw a1, enemy_y_2, t1
	sw a0, enemy_x_2, t1

	.kill_enemy_2:
	
	#Genera el random
	lw a0, random_seed_2
	rdtime a1
	xor a1, a1, a0
    	li a2, 200
    	remu a0, a1, a2
    	add a3, zero, a0

	
            # Ajusta la dirección basada en el número aleatorio
    	    addi t0,zero, MOV_STAY 
    	    beq a3, t0, .no_move_2
    	    
    	    addi t0,zero,  MOV_UP
   	    beq a3, t0, .move_up_2 
   	    
    	    addi t0,zero, MOV_DOWN
    	    beq a3, t0, .move_down_2
    	    
   	    addi t0, zero, MOV_RIGHT
    	    beq a3, t0, .move_right_2
    	    
    	    addi t0, zero, MOV_LEFT
    	    beq a3, t0, .move_left_2
	    j .no_move
	    
	.move_up_2:
	    lw a0, enemy_x_2
	    lw a1, enemy_y_2
	    lw a2, color_black
	    jal draw_point
	    addi a1, a1, -1
	    #collsion
	    jal draw_black
	    lw a4, color_black
	    bne a4, a2, .move_up_2_red
	    
	    sw a0, enemy_x_2, t1
	    sw a1, enemy_y_2, t1
	    lw a2, color_yellow	 
	    jal draw_point
	    j .no_move
	    
	.move_up_2_red:
	    lw a0, enemy_x_2
	    lw a1, enemy_y_2
	    lw a2, color_black
	    jal draw_point
	    addi a1, a1, -1
	    #collsion
	    jal draw_black
	    lw a4, color_red
	    bne a4, a2, .no_move
	    
	    sw a0, enemy_x_2, t1
	    sw a1, enemy_y_2, t1
	    lw a2, color_yellow	 
	    jal draw_point
	    j .no_move
	
	.move_down_2:
	    lw a0, enemy_x_2
	    lw a1, enemy_y_2
	    lw a2, color_black
	    jal draw_point
	    addi a1, a1, 1
	    #collision
	    jal draw_black
	    lw a4, color_black
	    bne a4, a2, .move_down_2_red 
	      
    	    sw a0, enemy_x_2, t1
	    sw a1, enemy_y_2, t1
	    lw a2, color_yellow
	    jal draw_point
	    j .no_move
	    
	.move_down_2_red:
	    lw a0, enemy_x_2
	    lw a1, enemy_y_2
	    lw a2, color_black
	    jal draw_point
	    addi a1, a1, 1
	    #collision
	    jal draw_black
	    lw a4, color_red
	    bne a4, a2, .no_move 
	      
    	    sw a0, enemy_x_2, t1
	    sw a1, enemy_y_2, t1
	    lw a2, color_yellow
	    jal draw_point
	    j .no_move
	    	    
	.move_right_2:
	    lw a0, enemy_x_2
	    lw a1, enemy_y_2
	    lw a2, color_black
	    jal draw_point
	    addi a0, a0, 1
	    #collision
	    jal draw_black
	    lw a4, color_black
	    bne a4, a2, .move_right_2_red
	    	    
    	    sw a0, enemy_x_2, t1
	    sw a1, enemy_y_2, t1
	    lw a2, color_yellow
	    jal draw_point
	    j .no_move
	    
	.move_right_2_red:
	    lw a0, enemy_x_2
	    lw a1, enemy_y_2
	    lw a2, color_black
	    jal draw_point
	    addi a0, a0, 1
	    #collision
	    jal draw_black
	    lw a4, color_red
	    bne a4, a2, .no_move
	    	    
    	    sw a0, enemy_x_2, t1
	    sw a1, enemy_y_2, t1
	    lw a2, color_yellow
	    jal draw_point
	    j .no_move	
	        
	.move_left_2:
	    lw a0, enemy_x_2
	    lw a1, enemy_y_2
	    lw a2, color_black
	    jal draw_point
	    addi a0, a0, -1
	    #collision
	    jal draw_black
	    lw a4, color_black
	    bne a4, a2, .move_left_2_red
	    	    
	    sw a0, enemy_x_2, t1
	    sw a1, enemy_y_2, t1
	    lw a2, color_yellow
	    jal draw_point
	    j .no_move
	    
	.move_left_2_red:
	    lw a0, enemy_x_2
	    lw a1, enemy_y_2
	    lw a2, color_black
	    jal draw_point
	    addi a0, a0, -1
	    #collision
	    jal draw_black
	    lw a4, color_red
	    bne a4, a2, .no_move
	    	    
	    sw a0, enemy_x_2, t1
	    sw a1, enemy_y_2, t1
	    lw a2, color_yellow
	    jal draw_point
	    j .no_move
		
	.no_move_2:
	    lw a0, enemy_x_2
	    lw a1, enemy_y_2
	    sw a0, enemy_x_2, t1
	    sw a1, enemy_y_2, t1
	    
	lw ra, 0(sp)
	addi sp, sp, 4
    	jr ra
#######################################################################################################
draw_enemies_3:

	addi sp, sp, -4
	sw ra, 0(sp)
	
	#Dibuja
	lw a0, enemy_x_3
	lw a1, enemy_y_3
	lw a2, color_blue
	jal draw_point
	
	#Verifica si la posicion del jugador coincide con el enemigo
	lw t0, player_x
	lw t2, player_y
	bne a0, t0, .da
	bne a1, t2, .da
	li t0, 6
	li t2, 5
	sw t0, player_x, t1
	sw t2, player_y, t1 
	
	.da:	
	#Si erase_enemy es un 1, lo manda a volar
	lw t2, erase_enemy_3
	li t3, 1
	bne t2, t3, .kill_enemy_3
	li a0, 200
	li a1, 200
	sw a1, enemy_y_3, t1
	sw a0, enemy_x_3, t1

	.kill_enemy_3:
	
	#Genera el random
	lw a0, random_seed_3
	rdtime a1
	xor a1, a1, a0
    	li a2, 200
    	remu a0, a1, a2
    	add a3, zero, a0

	
            # Ajusta la dirección basada en el número aleatorio
    	    addi t0,zero, MOV_STAY 
    	    beq a3, t0, .no_move_3
    	    
    	    addi t0,zero,  MOV_UP
   	    beq a3, t0, .move_up_3 
   	    
    	    addi t0,zero, MOV_DOWN
    	    beq a3, t0, .move_down_3
    	    
   	    addi t0, zero, MOV_RIGHT
    	    beq a3, t0, .move_right_3
    	    
    	    addi t0, zero, MOV_LEFT
    	    beq a3, t0, .move_left_3
	    j .no_move
	    
	.move_up_3:
	    lw a0, enemy_x_3
	    lw a1, enemy_y_3
	    lw a2, color_black
	    jal draw_point
	    addi a1, a1, -1
	    #collsion
	    jal draw_black
	    lw a4, color_black
	    bne a4, a2, .move_up_3_red
	    
	    sw a0, enemy_x_3, t1
	    sw a1, enemy_y_3, t1
	    lw a2, color_blue
	    jal draw_point
	    j .no_move
	    
	.move_up_3_red:
	    lw a0, enemy_x_3
	    lw a1, enemy_y_3
	    lw a2, color_black
	    jal draw_point
	    addi a1, a1, -1
	    #collsion
	    jal draw_black
	    lw a4, color_red
	    bne a4, a2, .no_move
	    
	    sw a0, enemy_x_3, t1
	    sw a1, enemy_y_3, t1
	    lw a2, color_blue
	    jal draw_point
	    j .no_move

	
	.move_down_3:
	    lw a0, enemy_x_3
	    lw a1, enemy_y_3
	    lw a2, color_black
	    jal draw_point
	    addi a1, a1, 1
	    #collision
	    jal draw_black
	    lw a4, color_black
	    bne a4, a2, .move_down_3_red 
	      
    	    sw a0, enemy_x_3, t1
	    sw a1, enemy_y_3, t1
	    lw a2, color_blue
	    jal draw_point
	    j .no_move
	    
	.move_down_3_red:
	    lw a0, enemy_x_3
	    lw a1, enemy_y_3
	    lw a2, color_black
	    jal draw_point
	    addi a1, a1, 1
	    #collision
	    jal draw_black
	    lw a4, color_red
	    bne a4, a2, .no_move 
	      
    	    sw a0, enemy_x_3, t1
	    sw a1, enemy_y_3, t1
	    lw a2, color_blue
	    jal draw_point
	    j .no_move	    
	.move_right_3:
	    lw a0, enemy_x_3
	    lw a1, enemy_y_3
	    lw a2, color_black
	    jal draw_point
	    addi a0, a0, 1
	    #collision
	    jal draw_black
	    lw a4, color_black
	    bne a4, a2, .no_move
	    	    
    	    sw a0, enemy_x_3, t1
	    sw a1, enemy_y_3, t1
	    lw a2, color_blue
	    jal draw_point
	    j .no_move
	    
	.move_left_3:
	    lw a0, enemy_x_3
	    lw a1, enemy_y_3
	    lw a2, color_black
	    jal draw_point
	    addi a0, a0, -1
	    #collision
	    jal draw_black
	    lw a4, color_black
	    bne a4, a2, .move_left_3_red
	    	    
	    sw a0, enemy_x_3, t1
	    sw a1, enemy_y_3, t1
	    lw a2, color_blue
	    jal draw_point
	    j .no_move
	    
	.move_left_3_red:
	    lw a0, enemy_x_3
	    lw a1, enemy_y_3
	    lw a2, color_black
	    jal draw_point
	    addi a0, a0, -1
	    #collision
	    jal draw_black
	    lw a4, color_red
	    bne a4, a2, .no_move
	    	    
	    sw a0, enemy_x_3, t1
	    sw a1, enemy_y_3, t1
	    lw a2, color_blue
	    jal draw_point
	    j .no_move	
	.no_move_3:
	    lw a0, enemy_x_3
	    lw a1, enemy_y_3
	    sw a0, enemy_x_3, t1
	    sw a1, enemy_y_3, t1
	    
	lw ra, 0(sp)
	addi sp, sp, 4
    	jr ra
#####################################################################################################################

# Function: draw_player
# Parameters:
#	a0: player x position
#	a1: player top y position
#	a2: player color
#	a3: player direction
# Return:
#	a0: new top y position
#	a1: direction of the player
draw_player:
    addi sp, sp -20
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3

    li t0, MOV_STAY 
    beq t0, s3, .no_mov 

    li t0, MOV_UP
    beq t0, s3, .up
    
    li t0, MOV_DOWN
    beq t0, s3, .down
    
    li t0, MOV_RIGHT
    beq t0, s3, .right
    
    li t0, MOV_LEFT
    beq t0, s3, .left
   
    li t0, bomb
    beq t0, s3, .draw_bomb
    
    li t0, bomb_2
    beq t0, s3, .draw_bomb_2    
    
    #The default case is the up movement
    
    .up: 
        mv a0, s0 
        mv a1, s1 
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a1, a1 , -1
        jal draw_black
        lw a4, color_black
        bne a4, a2, .up_1
        
        #power_up_3
        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_pa
        #erase bottom point
        li t0, TOP_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, -2
        j .move
        
        .no_pa:
        #erase bottom point
        li t0, TOP_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, -1
        j .move
    #Verifica si el color que no es negro sea naranja     
    .up_1: 
        mv a0, s0 
        mv a1, s1 
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a1, a1 , -1
        jal draw_black
        lw a4, color_orange
        bne a4, a2, .up_2
        
        #power_up_3
        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_pa_1
        #erase bottom point
        li t0, TOP_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, -2
        j .move
        
        .no_pa_1:       
        #erase bottom point
        li t0, TOP_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, -1
        j .move    
    #Verifica si el color que no es negro sea yellow    
    .up_2: 
        mv a0, s0 
        mv a1, s1 
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a1, a1 , -1
        jal draw_black
        lw a4, color_yellow
        bne a4, a2, .up_3
        
         #power_up_3
        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_pa_2
        #erase bottom point
        li t0, TOP_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, -2
        j .move
        
        .no_pa_2:       
        #erase bottom point
        li t0, TOP_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, -1
        j .move 
    #Verifica si el color que no es negro sea yellow    
    .up_3: 
        mv a0, s0 
        mv a1, s1 
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a1, a1 , -1
        jal draw_black
        lw a4, color_blue
        bne a4, a2, .up_4
        
        #power_up_3
        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_pa_3
        #erase bottom point
        li t0, TOP_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, -2
        j .move
        
        .no_pa_3:      
        #erase bottom point
        li t0, TOP_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, -1
        j .move 
    #Verifica si el color que no es negro sea rosado para el portal   
    .up_4: 
        mv a0, s0 
        mv a1, s1 
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a1, a1 , -1
        jal draw_black
        lw a4, color_pink
        bne a4, a2, .up_5
        
        #power_up_3
        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_pa_4
        #erase bottom point
        li t0, TOP_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, -2
        j .move
        
        .no_pa_4:        
        #erase bottom point
        li t0, TOP_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, -1
        j .move
     #Verifica si el color que no es negro sea morado   
    .up_5: 
        mv a0, s0 
        mv a1, s1 
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a1, a1 , -1
        jal draw_black
        lw a4, color_purple
        bne a4, a2, .up_6
        
         #power_up_3
        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_pa_5
        #erase bottom point
        li t0, TOP_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, -2
        j .move
        
        .no_pa_5:       
        #erase bottom point
        li t0, TOP_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, -1
        j .move 
     #Verifica si el color que no es negro sea burdeos   
    .up_6: 
        mv a0, s0 
        mv a1, s1 
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a1, a1 , -1
        jal draw_black
        lw a4, color_burdeos
        bne a4, a2, .up_7
        
        #power_up_3
        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_pa_6
        #erase bottom point
        li t0, TOP_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, -2
        j .move
        
        .no_pa_6:       
        #erase bottom point
        li t0, TOP_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, -1
        j .move 
             #Verifica si el color que no es negro sea rosybrown  
    .up_7: 
        mv a0, s0 
        mv a1, s1 
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a1, a1 , -1
        jal draw_black
        lw a4, color_rosybrown
        bne a4, a2, .no_mov
        
        #power_up_3
        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_pa_7
        #erase bottom point
        li t0, TOP_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, -2
        j .move
        
        .no_pa_7:       
        #erase bottom point
        li t0, TOP_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, -1
        j .move                           
    .down:
        mv a0, s0
        mv a1, s1
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a1, a1 , 1
        jal draw_black
        lw a4, color_black
        bne a4, a2, .down_1
        
        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_pat
        #erase top point
        li t0, BOTTOM_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, 2
        j .move
        
        .no_pat:
        #erase top point
        li t0, BOTTOM_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, 1
        j .move
        
        
     #Verifica si el color que no es negro sea naranja  
    .down_1:
        mv a0, s0
        mv a1, s1
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a1, a1 , 1
        jal draw_black
        lw a4, color_orange
        bne a4, a2, .down_2

        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_pat_1
        #erase top point
        li t0, BOTTOM_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, 2
        j .move
        
        .no_pat_1:        
        #erase top point
        li t0, BOTTOM_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, 1
        j .move
     #Verifica si el color que no es negro sea amarillo  
    .down_2:
        mv a0, s0
        mv a1, s1
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a1, a1 , 1
        jal draw_black
        lw a4, color_yellow
        bne a4, a2, .down_3
  
        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_pat_2
        #erase top point
        li t0, BOTTOM_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, 2
        j .move
        
        .no_pat_2:      
        #erase top point
        li t0, BOTTOM_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, 1
        j .move
        
     #Verifica si el color que no es negro sea azul  
    .down_3:
        mv a0, s0
        mv a1, s1
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a1, a1 , 1
        jal draw_black
        lw a4, color_blue
        bne a4, a2, .down_4
  
        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_pat_3
        #erase top point
        li t0, BOTTOM_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, 2
        j .move
        
        .no_pat_3:    
        #erase top point
        li t0, BOTTOM_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, 1
        j .move  
              
     #Verifica si el color que no es negro sea rosado  
    .down_4:
        mv a0, s0
        mv a1, s1
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a1, a1 , 1
        jal draw_black
        lw a4, color_pink
        bne a4, a2, .down_5

        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_pat_4
        #erase top point
        li t0, BOTTOM_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, 2
        j .move
        
        .no_pat_4:        
        #erase top point
        li t0, BOTTOM_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, 1
        j .move 
        
     #Verifica si el color que no es negro sea morado 
    .down_5:
        mv a0, s0
        mv a1, s1
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a1, a1 , 1
        jal draw_black
        lw a4, color_purple
        bne a4, a2, .down_6

        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_pat_5
        #erase top point
        li t0, BOTTOM_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, 2
        j .move
        
        .no_pat_5:      
        #erase top point
        li t0, BOTTOM_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, 1
        j .move 
     #Verifica si el color que no es negro sea burdeos 
    .down_6:
        mv a0, s0
        mv a1, s1
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a1, a1 , 1
        jal draw_black
        lw a4, color_burdeos
        bne a4, a2, .down_7

        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_pat_6
        #erase top point
        li t0, BOTTOM_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, 2
        j .move
        
        .no_pat_6:       
        #erase top point
        li t0, BOTTOM_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, 1
        j .move    
             #Verifica si el color que no es negro sea rosybrown
    .down_7:
        mv a0, s0
        mv a1, s1
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a1, a1 , 1
        jal draw_black
        lw a4, color_rosybrown
        bne a4, a2, .no_mov
        
        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_pat_7
        #erase top point
        li t0, BOTTOM_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, 2
        j .move
        
        .no_pat_7:
        #erase top point
        li t0, BOTTOM_PADDLE_Y_ROW
        beq s1, t0, .no_mov
        addi s1, s1, 1
        j .move
            
    .left: 
        mv a0, s0
        mv a1, s1
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a0, a0 , -1
        jal draw_black
        lw a4, color_black
        bne a4, a2, .left_1
        #Power_up_3
   	lw t0, Patin_count
   	li t1, 1
        bne t0, t1, .no_pati
        li t0, BOTTOM_LEFT
        beq a0, t0, .no_mov
        addi s0, s0, -2
        j .move
        
        .no_pati:
        li t0, BOTTOM_LEFT
        beq a0, t0, .no_mov
        addi s0, s0, -1
        j .move
    #Verifica si el color que no es negro sea naranja     
    .left_1: 
        mv a0, s0
        mv a1, s1
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a0, a0 , -1
        jal draw_black
        lw a4, color_orange
        bne a4, a2, .left_2
        #Power_up_3
   	lw t0, Patin_count
   	li t1, 1
        bne t0, t1, .no_pati_1
        li t0, BOTTOM_LEFT
        beq a0, t0, .no_mov
        addi s0, s0, -2
        j .move
        
        .no_pati_1:       
        #erase left vertica
        li t0, BOTTOM_LEFT
        beq a0, t0, .no_mov
        addi s0, s0, -1
        j .move  
        
    #Verifica si el color que no es negro sea amarillo     
    .left_2: 
        mv a0, s0
        mv a1, s1
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a0, a0 , -1
        jal draw_black
        lw a4, color_yellow
        bne a4, a2, .left_3
        #Power_up_3
   	lw t0, Patin_count
   	li t1, 1
        bne t0, t1, .no_pati_2
        li t0, BOTTOM_LEFT
        beq a0, t0, .no_mov
        addi s0, s0, -2
        j .move
        
        .no_pati_2:        
        #erase left vertica
        li t0, BOTTOM_LEFT
        beq a0, t0, .no_mov
        addi s0, s0, -1
        j .move  
    #Verifica si el color que no es negro sea amarillo     
    .left_3: 
        mv a0, s0
        mv a1, s1
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a0, a0 , -1
        jal draw_black
        lw a4, color_blue
        bne a4, a2, .left_4

        #Power_up_3
   	lw t0, Patin_count
   	li t1, 1
        bne t0, t1, .no_pati_3
        li t0, BOTTOM_LEFT
        beq a0, t0, .no_mov
        addi s0, s0, -2
        j .move
        
        .no_pati_3:       
        #erase left vertica
        li t0, BOTTOM_LEFT
        beq a0, t0, .no_mov
        addi s0, s0, -1
        j .move 
   #Verifica si el color que no es negro sea amarillo     
    .left_4: 
        mv a0, s0
        mv a1, s1
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a0, a0 , -1
        jal draw_black
        lw a4, color_pink
        bne a4, a2, .left_5
        
        #Power_up_3
   	lw t0, Patin_count
   	li t1, 1
        bne t0, t1, .no_pati_4
        li t0, BOTTOM_LEFT
        beq a0, t0, .no_mov
        addi s0, s0, -2
        j .move
        
        .no_pati_4:       
        #erase left vertica
        li t0, BOTTOM_LEFT
        beq a0, t0, .no_mov
        addi s0, s0, -1
        j .move 
        
   #Verifica si el color que no es negro sea morado     
    .left_5: 
        mv a0, s0
        mv a1, s1
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a0, a0 , -1
        jal draw_black
        lw a4, color_purple
        bne a4, a2, .left_6
        
        #Power_up_3
   	lw t0, Patin_count
   	li t1, 1
        bne t0, t1, .no_pati_5
        li t0, BOTTOM_LEFT
        beq a0, t0, .no_mov
        addi s0, s0, -2
        j .move
        
        .no_pati_5:        
        #erase left vertica
        li t0, BOTTOM_LEFT
        beq a0, t0, .no_mov
        addi s0, s0, -1
        j .move   
   #Verifica si el color que no es negro sea burdeos    
    .left_6: 
        mv a0, s0
        mv a1, s1
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a0, a0 , -1
        jal draw_black
        lw a4, color_burdeos
        bne a4, a2, .left_7

        #Power_up_3
   	lw t0, Patin_count
   	li t1, 1
        bne t0, t1, .no_pati_6
        li t0, BOTTOM_LEFT
        beq a0, t0, .no_mov
        addi s0, s0, -2
        j .move
        
        .no_pati_6:      
        #erase left vertica
        li t0, BOTTOM_LEFT
        beq a0, t0, .no_mov
        addi s0, s0, -1
        j .move  
           #Verifica si el color que no es negro sea burdeos    
    .left_7: 
        mv a0, s0
        mv a1, s1
        
        #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a0, a0 , -1
        jal draw_black
        lw a4, color_rosybrown
        bne a4, a2, .no_mov

        #Power_up_3
   	lw t0, Patin_count
   	li t1, 1
        bne t0, t1, .no_pati_7
        li t0, BOTTOM_LEFT
        beq a0, t0, .no_mov
        addi s0, s0, -2
        j .move
        
        .no_pati_7:        
        #erase left vertica
        li t0, BOTTOM_LEFT
        beq a0, t0, .no_mov
        addi s0, s0, -1
        j .move                
    .right:
        mv a0, s0
        mv a1, s1
        
         #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a0, a0 , 1
        jal draw_black
        lw a4, color_black
        bne a4, a2, .right_1
        
        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_patin
        #erase right vertical
        li t0, BOTTOM_RIGHT
        beq s0, t0, .no_mov
        addi s0, s0, 2
        j .move 
        
        .no_patin:
        #erase right vertical
        li t0, BOTTOM_RIGHT
        beq s0, t0, .no_mov
        addi s0, s0, 1
        j .move
    #Verifica si el color que no es negro sea naranja       
    .right_1:
        mv a0, s0
        mv a1, s1
        
         #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a0, a0 , 1
        jal draw_black
        lw a4, color_orange
        bne a4, a2, .right_2
        
        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_patin_1
        #erase right vertical
        li t0, BOTTOM_RIGHT
        beq s0, t0, .no_mov
        addi s0, s0, 2
        j .move 
        .no_patin_1:
        #erase right vertical
        li t0, BOTTOM_RIGHT
        beq s0, t0, .no_mov
        addi s0, s0, 1
        j .move 
    #Verifica si el color que no es negro sea yellow       
    .right_2:
        mv a0, s0
        mv a1, s1
        
         #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a0, a0 , 1
        jal draw_black
        lw a4, color_yellow
        bne a4, a2, .right_3
        
        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_patin_2
        #erase right vertical
        li t0, BOTTOM_RIGHT
        beq s0, t0, .no_mov
        addi s0, s0, 2
        j .move 
        .no_patin_2:       
        #erase right vertical
        li t0, BOTTOM_RIGHT
        beq s0, t0, .no_mov
        addi s0, s0, 1
        j .move 
        
    #Verifica si el color que no es negro sea azul       
    .right_3:
        mv a0, s0
        mv a1, s1
        
         #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a0, a0 , 1
        jal draw_black
        lw a4, color_blue
        bne a4, a2, .right_4
        
        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_patin_3
        li t0, BOTTOM_RIGHT
        beq s0, t0, .no_mov
        addi s0, s0, 2
        j .move 
        
        .no_patin_3:      
        #erase right vertical
        li t0, BOTTOM_RIGHT
        beq s0, t0, .no_mov
        addi s0, s0, 1
        j .move 
    #Verifica si el color que no es negro sea rosado      
    .right_4:
        mv a0, s0
        mv a1, s1
        
         #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a0, a0 , 1
        jal draw_black
        lw a4, color_pink
        bne a4, a2, .right_5

        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_patin_4
        li t0, BOTTOM_RIGHT
        beq s0, t0, .no_mov
        addi s0, s0, 2
        j .move 
        
        .no_patin_4:        
        #erase right vertical
        li t0, BOTTOM_RIGHT
        beq s0, t0, .no_mov
        addi s0, s0, 1
        j .move 
        
    #Verifica si el color que no es negro sea morado     
    .right_5:
        mv a0, s0
        mv a1, s1
        
         #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a0, a0 , 1
        jal draw_black
        lw a4, color_purple
        bne a4, a2, .right_6

        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_patin_5
        li t0, BOTTOM_RIGHT
        beq s0, t0, .no_mov
        addi s0, s0, 2
        j .move 
        
        .no_patin_5:      
        #erase right vertical
        li t0, BOTTOM_RIGHT
        beq s0, t0, .no_mov
        addi s0, s0, 1
        j .move
    #Verifica si el color que no es negro sea burdeos     
    .right_6:
        mv a0, s0
        mv a1, s1
        
         #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a0, a0 , 1
        jal draw_black
        lw a4, color_burdeos
        bne a4, a2, .right_7
 
        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_patin_6
        li t0, BOTTOM_RIGHT
        beq s0, t0, .no_mov
        addi s0, s0, 2
        j .move 
        
        .no_patin_6:       
        #erase right vertical
        li t0, BOTTOM_RIGHT
        beq s0, t0, .no_mov
        addi s0, s0, 1
        j .move      
    #Verifica si el color que no es negro sea burdeos     
    .right_7:
        mv a0, s0
        mv a1, s1
        
         #Check_collision
     	lw a2, color_black
     	jal draw_point
        addi a0, a0 , 1
        jal draw_black
        lw a4, color_rosybrown
        bne a4, a2, .no_mov

        lw t0, Patin_count
        li t1, 1
        bne t0, t1, .no_patin_7
        li t0, BOTTOM_RIGHT
        beq s0, t0, .no_mov
        addi s0, s0, 2
        j .move 
        
        .no_patin_7:
        li t0, BOTTOM_RIGHT
        beq s0, t0, .no_mov
        addi s0, s0, 1
        j .move  
                                   
     .draw_bomb:
        #Colocar una bomba
     	lw t0, init_bomb
     	bne t0,zero , .no_draw_bomb
     	li t2, 1
     	sw t2,init_bomb, t1
     	
     	lw a0, player_x
     	lw a1, player_y
	lw a2, color_cyan
	#addi a0,a0, 1 
	sw a0, bomb_x, t1
        sw a1, bomb_y, t1
	jal draw_point  
	
	j .no_mov
    .draw_bomb_2:
          #Colocar una bomba
     	lw t0, init_bomb_2
     	bne t0,zero , .no_draw_bomb
     	li t2, 1
     	sw t2,init_bomb_2, t1
     	
    	li t3,1
	lw t4, count_bomb
	bne t3, t4, .no_draw_bomb
	lw a0, player_x
     	lw a1, player_y
	lw a2, color_cyan
	sw a0, bomb_x_2, t1
        sw a1, bomb_y_2, t1
	jal draw_point
	j .no_mov
	
    .no_draw_bomb:
            
    .no_mov:
        #set the return value to MOV_STAY
        li s3, MOV_STAY
    
    .move:
        mv a0, s0
        mv a1, s1

        li t0, PADDLE_LENGTH
        add a3, a1, t0
        jal draw_point


    # The return values of the new y-top position
    mv a0, s0
    mv a1, s1
    mv a2, s3

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    addi sp, sp 20
    
    jr ra
    		
#######################################################################################################
#a0 en y
#a1 en x
draw_walls:
    addi sp, sp, -4
    sw ra, 0(sp)
    #Wall superior
    lw a2, color_gray
    addi a0, zero, 0 
    addi a1, zero, 3
    addi a3, a0, 63
    jal draw_horizontal_line
    
    lw a2, color_gray
    addi a0, zero, 0
    addi a1, zero, 4
    addi a3, a0, 63
    jal draw_horizontal_line
    
    #Wall lower
    lw a2, color_gray
    addi a0, zero, 0 
    addi a1, zero, 30
    addi a3, a0, 63
    jal draw_horizontal_line
    
    lw a2, color_gray
    addi a0, zero, 0
    addi a1, zero, 31
    addi a3, a0, 63
    jal draw_horizontal_line
    
    #Wall left
    lw a2, color_gray
    addi a0, zero, 2 
    addi a1, zero, 0
    addi a3, a0, 30
    jal draw_vertical_line
    
    lw a2, color_gray
    addi a0, zero, 1
    addi a1, zero, 0
    addi a3, a0, 30
    jal draw_vertical_line
    
    lw a2, color_gray
    addi a0, zero, 0
    addi a1, zero, 0
    addi a3, a0, 30
    jal draw_vertical_line
    
    lw a2, color_gray
    addi a0, zero, 3
    addi a1, zero, 0
    addi a3, a0, 30
    jal draw_vertical_line
    
    #Wall right
    lw a2, color_gray
    addi a0, zero, 63 
    addi a1, zero, 0
    addi a3, a0, 30
    jal draw_vertical_line
    
    lw a2, color_gray
    addi a0, zero, 62
    addi a1, zero, 0
    addi a3, a0, 30
    jal draw_vertical_line
    
    lw a2, color_gray
    addi a0, zero, 61
    addi a1, zero, 0
    addi a3, a0, 30
    jal draw_vertical_line
    
    lw a2, color_gray
    addi a0, zero, 60
    addi a1, zero, 0
    addi a3, a0, 30
    jal draw_vertical_line


    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra		
################################################################################################################3
draw_solid_blocks:

addi sp, sp, -4
    sw ra, 0(sp)

    # Row 1
    lw a2, color_white
    addi a0, zero, 7
    addi a1, zero, 8  
    jal draw_point
    addi a0, zero, 8 
    jal draw_point
    addi a1, zero, 9
    addi a0, zero, 7
    jal draw_point
    addi a0, zero, 8 
    jal draw_point
  
    addi a1, zero, 8	
    addi a0, zero, 15 
    jal draw_point
    addi a0, zero, 16
    jal draw_point
    addi a1, zero, 9
    addi a0, zero, 15
    jal	draw_point
    addi a0, zero, 16
    jal draw_point
   
    addi a1, zero, 8
    addi a0, zero, 23 
    jal draw_point
    addi a0, zero, 24
    jal draw_point
    addi a1, zero, 9
    addi a0, zero, 23
    jal	draw_point
    addi a0, zero, 24
    jal draw_point
    
    addi a1, zero, 8
    addi a0, zero, 31 
    jal draw_point
    addi a0, zero, 32
    jal draw_point
    addi a1, zero, 9
    addi a0, zero, 31
    jal	draw_point
    addi a0, zero, 32
    jal draw_point
    
    addi a1, zero, 8
    addi a0, zero, 39 
    jal draw_point
    addi a0, zero, 40
    jal draw_point
    addi a1, zero, 9
    addi a0, zero, 39
    jal	draw_point
    addi a0, zero, 40
    jal draw_point
    
    addi a1, zero, 8
    addi a0, zero, 47 
    jal draw_point
    addi a0, zero, 48
    jal draw_point
    addi a1, zero, 9
    addi a0, zero, 47
    jal	draw_point
    addi a0, zero, 48
    jal draw_point
    
    addi a1, zero, 8
    addi a0, zero, 55
    jal draw_point
    addi a0, zero, 56
    jal draw_point
    addi a1, zero, 9
    addi a0, zero, 55
    jal	draw_point
    addi a0, zero, 56
    jal draw_point

    # Row 2
    addi a0, zero, 7  
    addi a1, zero, 14 
    jal draw_point
    addi a0, zero, 8 
    jal draw_point
    addi a1, zero, 15
    addi a0, zero, 7
    jal draw_point
    addi a0, zero, 8 
    jal draw_point
    
    addi a1, zero, 14
    addi a0, zero, 15 
    jal draw_point
    addi a0, zero, 16
    jal draw_point
    addi a1, zero, 15
    addi a0, zero, 15
    jal draw_point
    addi a0, zero, 16 
    jal draw_point
    
    addi a1, zero, 14
    addi a0, zero, 23 
    jal draw_point
    addi a0, zero, 24
    jal draw_point
    addi a1, zero, 15
    addi a0, zero, 23
    jal draw_point
    addi a0, zero, 24
    jal draw_point
    
    addi a1, zero, 14
    addi a0, zero, 31 
    jal draw_point
    addi a0, zero, 32
    jal draw_point
    addi a1, zero, 15
    addi a0, zero, 31
    jal draw_point
    addi a0, zero, 32 
    jal draw_point
    
    addi a1, zero, 14
    addi a0, zero, 39 
    jal draw_point
    addi a0, zero, 40
    jal draw_point
    addi a1, zero, 15
    addi a0, zero, 39
    jal draw_point
    addi a0, zero, 40 
    jal draw_point
    
    addi a1, zero, 14
    addi a0, zero, 47 
    jal draw_point
    addi a0, zero, 48
    jal draw_point
    addi a1, zero, 15
    addi a0, zero, 47
    jal draw_point
    addi a0, zero, 48 
    jal draw_point
    
    addi a1, zero, 14
    addi a0, zero, 55 
    jal draw_point
    addi a0, zero, 56
    jal draw_point
    addi a1, zero, 15
    addi a0, zero, 55
    jal draw_point
    addi a0, zero, 56
    jal draw_point

    # Row 3
    addi a0, zero, 7 
    addi a1, zero, 20 
    jal draw_point
    addi a0, zero, 8
    jal draw_point
    addi a1, zero, 21
    addi a0, zero, 7
    jal draw_point
    addi a0, zero, 8
    jal draw_point
  
    
    addi, a1, zero, 20
    addi a0, zero, 15 
    jal draw_point
    addi a0, zero, 16
    jal draw_point
    addi a1, zero, 21
    addi a0, zero, 15
    jal draw_point
    addi a0, zero, 16
    jal draw_point
    
    addi a1, zero, 20
    addi a0, zero, 23 
    jal draw_point
    addi a0, zero, 24
    jal draw_point
    addi a1, zero, 21
    addi a0, zero, 23
    jal draw_point
    addi a0, zero, 24
    jal draw_point
    
    addi a1, zero, 20
    addi a0, zero, 31 
    jal draw_point
    addi a0, zero, 32
    jal draw_point
    addi a1, zero, 21
    addi a0, zero, 31
    jal draw_point
    addi a0, zero, 32
    jal draw_point
    
    addi a1, zero, 20
    addi a0, zero, 39 
    jal draw_point
    addi a0, zero, 40
    jal draw_point
    addi a1, zero, 21
    addi a0, zero, 39
    jal draw_point
    addi a0, zero, 40
    jal draw_point
    
    addi a1, zero, 20
    addi a0, zero, 47 
    jal draw_point
    addi a0, zero, 48
    jal draw_point
    addi a1, zero, 21
    addi a0, zero, 47
    jal draw_point
    addi a0, zero, 48
    jal draw_point
    
    addi a1, zero, 20
    addi a0, zero, 55 
    jal draw_point
    addi a0, zero, 56
    jal draw_point
    addi a1, zero, 21
    addi a0, zero, 55
    jal draw_point
    addi a0, zero, 56
    jal draw_point


    # Row 4
    addi a0, zero, 7  
    addi a1, zero, 26 
    jal draw_point
    addi a0, zero, 8
    jal draw_point
    addi a1, zero, 27
    addi a0, zero, 7
    jal draw_point
    addi a0, zero, 8
    jal draw_point
     
    addi, a1, zero, 26
    addi a0, zero, 15 
    jal draw_point
    addi a0, zero, 16
    jal draw_point
    addi a1, zero, 27
    addi a0, zero, 15
    jal draw_point
    addi a0, zero, 16
    jal draw_point    
    
    addi a1, zero, 26
    addi a0, zero, 23 
    jal draw_point
    addi a0, zero, 24
    jal draw_point
    addi a1, zero, 27
    addi a0, zero, 23
    jal draw_point
    addi a0, zero, 24
    jal draw_point    
    
    addi a1, zero, 26
    addi a0, zero, 31
    jal draw_point
    addi a0, zero, 32
    jal draw_point
    addi a1, zero, 27
    addi a0, zero, 31
    jal draw_point
    addi a0, zero, 32
    jal draw_point    
    
    addi a1, zero, 26
    addi a0, zero, 39 
    jal draw_point
    addi a0, zero, 40
    jal draw_point
    addi a1, zero, 27
    addi a0, zero, 39
    jal draw_point
    addi a0, zero, 40
    jal draw_point    
    
    addi a1, zero, 26
    addi a0, zero, 47 
    jal draw_point
    addi a0, zero, 48
    jal draw_point
    addi a1, zero, 27
    addi a0, zero, 47
    jal draw_point
    addi a0, zero, 48
    jal draw_point    
    
    addi a1, zero, 26
    addi a0, zero, 55 
    jal draw_point
    addi a0, zero, 56
    jal draw_point
    addi a1, zero, 27
    addi a0, zero, 55
    jal draw_point
    addi a0, zero, 56
    jal draw_point    

    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra				

draw_destructible:

#a0 = x
#a1 = y

    addi sp, sp, -4
    sw ra, 0(sp)
    
    lw a2, color_green
    addi a0, zero, 15 
    addi a1, zero, 17
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 15 
    addi a1, zero, 18
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################
    
    lw a2, color_green
    addi a0, zero, 23
    addi a1, zero, 17
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 23
    addi a1, zero, 18
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################

    lw a2, color_green
    addi a0, zero, 23
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 23
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################
    
    lw a2, color_green
    addi a0, zero, 26
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 26
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################
    
    lw a2, color_green
    addi a0, zero, 29
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 29
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line   
    
    ######################### 
    
    lw a2, color_green
    addi a0, zero, 35
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 35
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line  
    
    ######################### 
    
    lw a2, color_green
    addi a0, zero, 35
    addi a1, zero, 14
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 35
    addi a1, zero, 15
    addi a3, a0, 1
    jal draw_horizontal_line 
    
    ######################### 
   
    lw a2, color_green
    addi a0, zero, 35
    addi a1, zero, 17
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 35
    addi a1, zero, 18
    addi a3, a0, 1
    jal draw_horizontal_line 
    
    ######################### 
    
    lw a2, color_green
    addi a0, zero, 35
    addi a1, zero, 20
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 35
    addi a1, zero, 21
    addi a3, a0, 1
    jal draw_horizontal_line 
    
    #########################
    
    lw a2, color_green
    addi a0, zero, 11
    addi a1, zero, 26
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 11
    addi a1, zero, 27
    addi a3, a0, 1
    jal draw_horizontal_line 
    
    #########################
    
    lw a2, color_green
    addi a0, zero, 11
    addi a1, zero, 23
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 11
    addi a1, zero, 24
    addi a3, a0, 1
    jal draw_horizontal_line 
    
    #########################
    
    lw a2, color_green
    addi a0, zero, 11
    addi a1, zero, 20
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 11
    addi a1, zero, 21
    addi a3, a0, 1
    jal draw_horizontal_line 
    
    #########################
    
    lw a2, color_green
    addi a0, zero, 45
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 45
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_green
    addi a0, zero, 48
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 48
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line

    #########################  
    
    lw a2, color_green
    addi a0, zero, 51
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 51
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line

    #########################  
    
    lw a2, color_green
    addi a0, zero, 54
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 54
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line
    
    ########################  
    
    lw a2, color_green
    addi a0, zero, 57
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 57
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_green
    addi a0, zero, 51
    addi a1, zero, 14
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 51
    addi a1, zero, 15
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_green
    addi a0, zero, 51
    addi a1, zero, 7
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 51
    addi a1, zero, 8
    addi a3, a0, 1
    jal draw_horizontal_line
   
    #########################  
    
    lw a2, color_green
    addi a0, zero, 26
    addi a1, zero, 7
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 26
    addi a1, zero, 8
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_green
    addi a0, zero, 26
    addi a1, zero, 26
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 26
    addi a1, zero, 27
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_green
    addi a0, zero, 11
    addi a1, zero, 14
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 11
    addi a1, zero, 15
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_green
    addi a0, zero, 51
    addi a1, zero, 26
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 51
    addi a1, zero, 27
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_green
    addi a0, zero, 51
    addi a1, zero, 23
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 51
    addi a1, zero, 24
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_green
    addi a0, zero, 48
    addi a1, zero, 23
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 48
    addi a1, zero, 24
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_green
    addi a0, zero, 47
    addi a1, zero, 17
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_green
    addi a0, zero, 47
    addi a1, zero, 18
    addi a3, a0, 1
    jal draw_horizontal_line


    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra


##################################################################################################################################
# Function: draw_score
# Parameters:
#	a0: score of the player
#	a1: column of the leftmost scoring dot
# Return:
#	void
draw_score:
	addi sp, sp, -16
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw a0, 12(sp)
	
	mv s0, a0
	mv s1, a1
	li t0, SCORE_FIRST_ROW_POINTS
	ble s0, t0, .score_row_1
	
	.score_row_2:
	li  t0, SCORE_SECOND_ROW_POINTS
	sub t0, s0, t0
	li t1, 1
	sll t0, t0, t1
	add a0, t0, s1 
	li a1, ROW_3
	lw a2, color_white 
	jal draw_point
	
	addi s0, s0, -1
	li t0, SCORE_SECOND_ROW_POINTS
	bge s0, t0, .score_row_2
	
	.score_row_1:
	beq s0, zero, .score_end
	addi t0, s0, -1
	li t1, 1 # I put the number here directly without label because its use is evident
	sll t0, t0, t1
	add a0, t0, s1 
	li a1, ROW_1
	lw a2, color_white 
	jal draw_point
	
	addi s0, s0, -1
	j .score_row_1
	
	.score_end:
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw a0, 12(sp)
	addi sp, sp, 16
	
	jr ra
	
###############################################################################################################################	
draw_black:
	li t0, 6
	sll t0, a1, t0 #Due to the size of the screen, multiply y coodinate by 64 (length of the field)
	add t1, a0, t0
	li t0, 2
	sll t1, t1, t0 # Multiply the resulting coodinate by 4
	add t1, t1, gp
	lw a2, (t1)
	ret 
	
###############################################################################################################################	
# Function: draw_point
# Parameters:
#	a0: x coordinate
#	a1: y coordinate
#	a2: color of the point
# Return
#	void
draw_point:
	li t0, 6
	sll t0, a1, t0 #Due to the size of the screen, multiply y coodinate by 64 (length of the field)
	add t1, a0, t0
	li t0, 2
	sll t1, t1, t0 # Multiply the resulting coodinate by 4
	add t1, t1, gp
	sw a2, (t1)
	jr ra

# Function: draw_horizontal_line
# Parameters:
#	a0: starting x coordinate
#	a1: y coordinate
#	a2: color of the line
#	a3: ending x coordinate
# Return
#	void
draw_horizontal_line:
	
	addi sp, sp, -16
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	
	sub s0, a3, a0
	mv s1, a0
	li s2, 0
	
	.horizontal_loop:
		add a0, s1, s0
		jal draw_point
		addi s0, s0, -1
		
		bge s0, s2, .horizontal_loop
	
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	addi sp, sp, 16	
	
	jr ra

# Function: draw_vertical_line
# Parameters:
#	a0: x coordinate
#	a1: starting y coordinate
#	a2: color of the line
#	a3: ending y coordinate
# Return
#	void
draw_vertical_line:
	
	addi sp, sp, -16
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	
	sub s0, a3, a1
	mv s1, a1
	li s2, 0
	
	.vertical_loop:
		add a1, s1, s0
		jal draw_point
		addi s0, s0, -1
		
		bge s0, s2, .vertical_loop
	
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	
	addi sp, sp, 16	
	
	jr ra
	
# Function: clear_board
# Parameters:
#	none
# Return
#	void
clear_board:
	lw t0, color_black
	li t1, TOTAL_PIXELS
	li t2, FOUR_BYTES
	
	.start_clear_loop:
		sub t1, t1, t2
		add t3, t1, gp
		sw t0, (t3)
		beqz t1, .end_clear_loop
		j .start_clear_loop
		
	.end_clear_loop:
	
	jr ra
	
# Function: draw_title_screen
# Parameters:
#	none
# Return
#	void
draw_title_screen:

	addi sp, sp, -4
	sw ra, 0(sp)

# The upper lines
	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	lw a2, color_blue
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	addi a1, a1, 1
	lw a2, color_white
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	addi a1, a1, 2
	lw a2, color_red
	li a3, 63
	jal draw_horizontal_line
	
	# The below lines
	li a0, 0
	li a1, TITLE_SCREEN_SECOND_LINE_ROW_Y
	lw a2, color_red
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_SECOND_LINE_ROW_Y
	addi a1, a1, 1
	lw a2, color_white
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_SECOND_LINE_ROW_Y
	addi a1, a1, 2
	lw a2, color_blue
	li a3, 63
	jal draw_horizontal_line
	
	#Bomberman text
	#The B
	li a0, PONG_TEXT_X
	li a1, PONG_TEXT_Y
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 4
	li a1, PONG_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 1
	li a1, PONG_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 1
	li a1, PONG_TEXT_Y
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 1
	li a1, PONG_TEXT_Y
	addi a1, a1, 6
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 4
	li a1, PONG_TEXT_Y
	addi a1, a1, 4
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	# The O
	li a0, PONG_TEXT_X
	addi a0, a0, 6
	li a1, PONG_TEXT_Y
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 10
	li a1, PONG_TEXT_Y
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 6
	li a1, PONG_TEXT_Y
	lw a2, color_white
	addi a3, a0, 3
	jal draw_horizontal_line

	li a0, PONG_TEXT_X
	addi a0, a0, 6
	li a1, PONG_TEXT_Y
	addi a1,  a1, 6
	lw a2, color_white
	addi a3, a0, 3
	jal draw_horizontal_line
	
	#The M
	li a0, PONG_TEXT_X
	addi a0, a0, 12
	li a1, PONG_TEXT_Y
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 16
	li a1, PONG_TEXT_Y
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 14
	li a1, PONG_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 12
	li a1, PONG_TEXT_Y
	lw a2, color_white
	addi a3, a0, 3
	jal draw_horizontal_line
	
	#The B
	li a0, PONG_TEXT_X
	addi a0, a0, 18
	li a1, PONG_TEXT_Y
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 22
	li a1, PONG_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 19
	li a1, PONG_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 19
	li a1, PONG_TEXT_Y
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 19
	li a1, PONG_TEXT_Y
	addi a1, a1, 6
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 22
	li a1, PONG_TEXT_Y
	addi a1, a1, 4
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	#The E
	li a0, PONG_TEXT_X
	addi a0, a0, 24
	li a1, PONG_TEXT_Y
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 24
	li a1, PONG_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a0, 1
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 24
	li a1, PONG_TEXT_Y
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 24
	li a1, PONG_TEXT_Y
	addi a1, a1, 6
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	#The R
	li a0, PONG_TEXT_X
	addi a0, a0, 28
	li a1, PONG_TEXT_Y
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 28
	li a1, PONG_TEXT_Y
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 28
	li a1, PONG_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 31
	li a1, PONG_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 31
	li a1, PONG_TEXT_Y
	addi a1, a1, 4
	lw a2, color_white
	addi a3, a1, 2
	jal draw_vertical_line
	
	#The M
	li a0, PONG_TEXT_X
	addi a0, a0, 33
	li a1, PONG_TEXT_Y
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 37
	li a1, PONG_TEXT_Y
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 35
	li a1, PONG_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 33
	li a1, PONG_TEXT_Y
	lw a2, color_white
	addi a3, a0, 3
	jal draw_horizontal_line
	
	#The A
	li a0, PONG_TEXT_X
	addi a0, a0, 39
	li a1, PONG_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 43
	li a1, PONG_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line

	li a0, PONG_TEXT_X
	addi a0, a0, 40
	li a1, PONG_TEXT_Y
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 40
	li a1, PONG_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	#The N
	li a0, PONG_TEXT_X
	addi a0, a0, 45
	li a1, PONG_TEXT_Y
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 51
	li a1, PONG_TEXT_Y
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 46
	li a1, PONG_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, 0
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 47
	li a1, PONG_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, 1
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 48
	li a1, PONG_TEXT_Y
	addi a1, a1, 4
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, 2
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 48
	li a1, PONG_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, 4
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 49
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, 5
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 50
	li a1, PONG_TEXT_Y
	addi a1, a1, 6
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, 6
	jal draw_vertical_line

	#Press text
	
	# The P
	li a0, PRESS_TEXT_X
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 3
	li a1, PRESS_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 1
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 1
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	# The R
	li a0, PRESS_TEXT_X
	addi a0, a0, 5
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 7
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 7
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_black
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 6
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	jal draw_point

	li a0, PRESS_TEXT_X
	addi a0, a0, 6
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	jal draw_point
			
	#The E
	li a0, PRESS_TEXT_X
	addi a0, a0, 9
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 10
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 10
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 10
	li a1, PRESS_TEXT_Y
	addi a1, a1, 4
	lw a2, color_white
	jal draw_point
	
	# The first S
	li a0, PRESS_TEXT_X
	addi a0, a0, 12
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 12
	li a1, PRESS_TEXT_Y
	addi a1, a1, 3
	lw a2, color_black
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 13
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 13
	li a1, PRESS_TEXT_Y
	addi a1,  a1, 2
	lw a2, color_white
	jal draw_point

	li a0, PRESS_TEXT_X
	addi a0, a0, 13
	li a1, PRESS_TEXT_Y
	addi a1,  a1, 4
	lw a2, color_white
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 14
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line

	li a0, PRESS_TEXT_X
	addi a0, a0, 14
	li a1, PRESS_TEXT_Y
	addi a1,  a1, 1
	lw a2, color_black
	jal draw_point

	# The other S	
	li a0, PRESS_TEXT_X
	addi a0, a0, 23
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 23
	li a1, PRESS_TEXT_Y
	addi a1, a1, 3
	lw a2, color_black
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 24
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 24
	li a1, PRESS_TEXT_Y
	addi a1,  a1, 2
	lw a2, color_white
	jal draw_point

	li a0, PRESS_TEXT_X
	addi a0, a0, 24
	li a1, PRESS_TEXT_Y
	addi a1,  a1, 4
	lw a2, color_white
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 25
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line

	li a0, PRESS_TEXT_X
	addi a0, a0, 25
	li a1, PRESS_TEXT_Y
	addi a1,  a1, 1
	lw a2, color_black
	jal draw_point
	
	#Space text
	
	#The S
	li a0, PRESS_TEXT_X
	addi a0, a0, 16
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 16
	li a1, PRESS_TEXT_Y
	addi a1, a1, 3
	lw a2, color_black
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 17
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 17
	li a1, PRESS_TEXT_Y
	addi a1,  a1, 2
	lw a2, color_white
	jal draw_point

	li a0, PRESS_TEXT_X
	addi a0, a0, 17
	li a1, PRESS_TEXT_Y
	addi a1,  a1, 4
	lw a2, color_white
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 18
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line

	li a0, PRESS_TEXT_X
	addi a0, a0, 18
	li a1, PRESS_TEXT_Y
	addi a1,  a1, 1
	lw a2, color_black
	jal draw_point
	
	#The P
	li a0, PRESS_TEXT_X
	addi a0, a0, 27 
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 30
	li a1, PRESS_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 28
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 28
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	#The A
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 32
	li a1, PRESS_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	li a3, PRESS_TEXT_Y
	addi a3, a3, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 36
	li a1, PRESS_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	li a3, PRESS_TEXT_Y
	addi a3, a3, PRESS_TEXT_H
	jal draw_vertical_line

	li a0, PRESS_TEXT_X
	addi a0, a0, 33
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 33
	li a1, PRESS_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	#The C
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 38 
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 39
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 39
	li a1, PRESS_TEXT_Y
	addi a1, a1, 4
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	#The E
	li a0, PRESS_TEXT_X
	addi a0, a0, 43
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 44
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 44
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 44
	li a1, PRESS_TEXT_Y
	addi a1, a1, 4
	lw a2, color_white
	jal draw_point
			
			
	lw ra, 0(sp)
	addi sp, sp, 4
	
	jr ra 

draw_destructible_2:

#a0 = x
#a1 = y

    addi sp, sp, -4
    sw ra, 0(sp)
    
    lw a2, color_brown
    addi a0, zero, 11
    addi a1, zero, 17
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 11
    addi a1, zero, 18
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################
    
    lw a2, color_brown
    addi a0, zero, 26
    addi a1, zero, 17
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 26
    addi a1, zero, 18
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################

    lw a2, color_brown
    addi a0, zero, 23
    addi a1, zero, 5
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 23
    addi a1, zero, 6
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################
    
    lw a2, color_brown
    addi a0, zero, 15
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 15
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################
    
    lw a2, color_brown
    addi a0, zero, 29
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 29
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line   
    
    ######################### 
    
    lw a2, color_brown
    addi a0, zero, 35
    addi a1, zero, 8
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 35
    addi a1, zero, 9
    addi a3, a0, 1
    jal draw_horizontal_line  
    
    ######################### 
    
    lw a2, color_brown
    addi a0, zero, 35
    addi a1, zero, 14
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 35
    addi a1, zero, 15
    addi a3, a0, 1
    jal draw_horizontal_line 
    
    ######################### 
   
    lw a2, color_brown
    addi a0, zero, 29
    addi a1, zero, 17
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 29
    addi a1, zero, 18
    addi a3, a0, 1
    jal draw_horizontal_line 
    
    ######################### 
    
    lw a2, color_brown
    addi a0, zero, 35
    addi a1, zero, 26
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 35
    addi a1, zero, 27
    addi a3, a0, 1
    jal draw_horizontal_line 
    
    #########################
    
    lw a2, color_brown
    addi a0, zero, 4
    addi a1, zero, 16
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 4
    addi a1, zero, 17
    addi a3, a0, 1
    jal draw_horizontal_line 
    
    #########################
    
    lw a2, color_brown
    addi a0, zero, 18
    addi a1, zero, 23
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 18
    addi a1, zero, 24
    addi a3, a0, 1
    jal draw_horizontal_line 
    
    #########################
    
    lw a2, color_brown
    addi a0, zero, 11
    addi a1, zero, 8
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 11
    addi a1, zero, 9
    addi a3, a0, 1
    jal draw_horizontal_line 
    
    #########################
    
    lw a2, color_brown
    addi a0, zero, 18
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 18
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_brown
    addi a0, zero, 42
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 42
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line

    #########################  
    
    lw a2, color_brown
    addi a0, zero, 47
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 47
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line

    #########################  
    
    lw a2, color_brown
    addi a0, zero, 54
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 54
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line
    
    ########################  
    
    lw a2, color_brown
    addi a0, zero, 57
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 57
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_brown
    addi a0, zero, 51
    addi a1, zero, 14
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 51
    addi a1, zero, 15
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_brown
    addi a0, zero, 51
    addi a1, zero, 7
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 51
    addi a1, zero, 8
    addi a3, a0, 1
    jal draw_horizontal_line
   
    #########################  
    
    lw a2, color_brown
    addi a0, zero, 26
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 26
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_brown
    addi a0, zero, 26
    addi a1, zero, 26
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 26
    addi a1, zero, 27
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_brown
    addi a0, zero, 11
    addi a1, zero, 14
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 11
    addi a1, zero, 15
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_brown
    addi a0, zero, 51
    addi a1, zero, 26
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 51
    addi a1, zero, 27
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_brown
    addi a0, zero, 51
    addi a1, zero, 23
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 51
    addi a1, zero, 24
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_brown
    addi a0, zero, 48
    addi a1, zero, 23
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 48
    addi a1, zero, 24
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_brown
    addi a0, zero, 47
    addi a1, zero, 17
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_brown
    addi a0, zero, 47
    addi a1, zero, 18
    addi a3, a0, 1
    jal draw_horizontal_line


    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra
draw_game_over:
	
	addi sp, sp, -4
	sw ra, 0(sp)
	
	# The upper lines
	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	lw a2, color_blue
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	addi a1, a1, 1
	lw a2, color_white
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	addi a1, a1, 2
	lw a2, color_red
	li a3, 63
	jal draw_horizontal_line
	
	# The below lines
	li a0, 0
	li a1, TITLE_SCREEN_SECOND_LINE_ROW_Y
	lw a2, color_red
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_SECOND_LINE_ROW_Y
	addi a1, a1, 1
	lw a2, color_white
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_SECOND_LINE_ROW_Y
	addi a1, a1, 2
	lw a2, color_blue
	li a3, 63
	jal draw_horizontal_line
	
	#Game over text
	#The G
	li a0, PONG_TEXT_X
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, 11
	jal draw_vertical_line

	li a0, PONG_TEXT_X
	addi a0, a0, 1
	li a1, PONG_TEXT_Y
	addi a1, a1, 12
	lw a2, color_white
	addi a3, a0, 3
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 1
	li a1, PONG_TEXT_Y
	addi a1, a1, 6
	lw a2, color_white
	addi a3, a0, 4
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 2
	li a1, PONG_TEXT_Y
	addi a1, a1, 9
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 5
	li a1, PONG_TEXT_Y
	addi a1, a1, 10
	lw a2, color_white
	jal draw_point
	
	li a0, PONG_TEXT_X
	addi a0, a0, 5
	li a1, PONG_TEXT_Y
	addi a1, a1, 11
	lw a2, color_white
	jal draw_point

	#The A
	li a0, PONG_TEXT_X
	addi a0, a0, 7
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, 12
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 11
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, 12
	jal draw_vertical_line

	li a0, PONG_TEXT_X
	addi a0, a0, 8
	li a1, PONG_TEXT_Y
	addi a1, a1, 6
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 8
	li a1, PONG_TEXT_Y
	addi a1, a1, 9
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	#The M
	li a0, PONG_TEXT_X
	addi a0, a0, 13
	li a1, PONG_TEXT_Y
	addi a1, a1, 6
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, 12
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 17
	li a1, PONG_TEXT_Y
	addi a1, a1, 6
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, 12
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 15
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 14
	li a1, PONG_TEXT_Y
	addi a1, a1, 6
	lw a2, color_white
	addi a3, a0, 3
	jal draw_horizontal_line
	
	#The E
	li a0, PONG_TEXT_X
	addi a0, a0, 19
	li a1, PONG_TEXT_Y
	addi a1, a1, 6
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, 12
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 19
	li a1, PONG_TEXT_Y
	addi a1, a1, 9
	lw a2, color_white
	addi a3, a0, 1
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 19
	li a1, PONG_TEXT_Y
	addi a1, a1, 6
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 19
	li a1, PONG_TEXT_Y
	addi a1, a1, 12
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line

	# The O
	li a0, PONG_TEXT_X
	addi a0, a0, 26
	li a1, PONG_TEXT_Y
	addi a1, a1, 6
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, 12
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 30
	li a1, PONG_TEXT_Y
	addi a1, a1, 6
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, 12
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 27
	li a1, PONG_TEXT_Y
	addi a1, a1, 6
	lw a2, color_white
	addi a3, a0, 3
	jal draw_horizontal_line

	li a0, PONG_TEXT_X
	addi a0, a0, 27
	li a1, PONG_TEXT_Y
	addi a1,  a1, 12
	lw a2, color_white
	addi a3, a0, 3
	jal draw_horizontal_line
	
	#The V
	li a0, PONG_TEXT_X
	addi a0, a0, 32
	li a1, PONG_TEXT_Y
	addi a1, a1, 6
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 4
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 39
	li a1, PONG_TEXT_Y
	addi a1, a1, 11
	lw a2, color_white
	addi a3, a3, 24
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 40
	li a1, PONG_TEXT_Y
	addi a1, a1, 12
	lw a2, color_white
	addi a3, a3, 1
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 41
	li a1, PONG_TEXT_Y
	addi a1, a1, 11
	lw a2, color_white
	addi a3, a3, 1
	jal draw_horizontal_line

	li a0, PONG_TEXT_X
	addi a0, a0, 36
	li a1, PONG_TEXT_Y
	addi a1, a1, 6
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 4
	jal draw_vertical_line
	
	#The E
	li a0, PONG_TEXT_X
	addi a0, a0, 38
	li a1, PONG_TEXT_Y
	addi a1, a1, 6
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 6
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 38
	li a1, PONG_TEXT_Y
	addi a1, a1, 9
	lw a2, color_white
	addi a3, a0, 1
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 38
	li a1, PONG_TEXT_Y
	addi a1, a1, 6
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 38
	li a1, PONG_TEXT_Y
	addi a1, a1, 12
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	#The R
	li a0, PONG_TEXT_X
	addi a0, a0, 42
	li a1, PONG_TEXT_Y
	addi a1, a1, 6
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, 12
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 43
	li a1, PONG_TEXT_Y
	addi a1, a1, 6
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 43
	li a1, PONG_TEXT_Y
	addi a1, a1, 9
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 46
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 46
	li a1, PONG_TEXT_Y
	addi a1, a1, 10
	lw a2, color_white
	addi a3, a1, 2
	jal draw_vertical_line


		.pause_5:
		li a0, 3000
		li a7, 32	
		ecall		#Pause for 100 milisec
		
	jal clear_key_status
	
	.reset_wait_5:
		li a0, 10
		li a7, 32 
		ecall		#Pause for 100 milisec
		
		li t0, KEY_STATUS_ADDRESS
		beq t0, zero, .reset_wait_5
		j .reset_5
	
	.reset_5:
		sw zero, p1_score, t0
		sw zero, p2_score, t0
		jal clear_key_status
		jal clear_key_press
		jal clear_board
		j new_game
		
	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra 
draw_level_1:

	addi sp, sp, -4
	sw ra, 0(sp)

	# The upper lines
	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	lw a2, color_blue
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	addi a1, a1, 1
	lw a2, color_white
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	addi a1, a1, 2
	lw a2, color_red
	li a3, 63
	jal draw_horizontal_line
	
	# The below lines
	li a0, 0
	li a1, TITLE_SCREEN_SECOND_LINE_ROW_Y
	lw a2, color_red
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_SECOND_LINE_ROW_Y
	addi a1, a1, 1
	lw a2, color_white
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_SECOND_LINE_ROW_Y
	addi a1, a1, 2
	lw a2, color_blue
	li a3, 63
	jal draw_horizontal_line
	
	#Level 1 text
	
	#The L
		
	li a0, PONG_TEXT_X
	addi a0, a0, 12
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 7
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 12
	li a1, PONG_TEXT_Y
	addi a1, a1, 13
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	#The E
	li a0, PONG_TEXT_X
	addi a0, a0, 16
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 7
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 16
	li a1, PONG_TEXT_Y
	addi a1, a1, 10
	lw a2, color_white
	addi a3, a0, 1
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 16
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 16
	li a1, PONG_TEXT_Y
	addi a1, a1, 13
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	#The V
	li a0, PONG_TEXT_X
	addi a0, a0, 20
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 5
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 22
	li a1, PONG_TEXT_Y
	addi a1, a1, 12
	lw a2, color_white
	addi a3, a3, 11
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 23
	li a1, PONG_TEXT_Y
	addi a1, a1, 13
	lw a2, color_white
	addi a3, a3, 1
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 24
	li a1, PONG_TEXT_Y
	addi a1, a1, 12
	lw a2, color_white
	addi a3, a3, 1
	jal draw_horizontal_line

	li a0, PONG_TEXT_X
	addi a0, a0, 24
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 5
	jal draw_vertical_line
	
	#The E
	li a0, PONG_TEXT_X
	addi a0, a0, 26
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 7
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 26
	li a1, PONG_TEXT_Y
	addi a1, a1, 10
	lw a2, color_white
	addi a3, a0, 1
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 26
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 26
	li a1, PONG_TEXT_Y
	addi a1, a1, 13
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	#The L
	
	li a0, PONG_TEXT_X
	addi a0, a0, 30
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 7
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 30
	li a1, PONG_TEXT_Y
	addi a1, a1, 13
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	#The 1
	li a0, PONG_TEXT_X
	addi a0, a0, 36
	li a1, PONG_TEXT_Y
	addi a1, a1, 8
	lw a2, color_white
	addi a3, a3, 4
	jal draw_horizontal_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 37
	li a1, PONG_TEXT_Y
	addi a1, a1, 7
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	addi a3, a3, 7
	jal draw_vertical_line
	
	li a0, PONG_TEXT_X
	addi a0, a0, 36
	li a1, PONG_TEXT_Y
	addi a1, a1, 13
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	.pause_6:
		li a0, 3000
		li a7, 32	
		ecall		#Pause for 100 milisec
		
	jal clear_key_status
	
	.reset_wait_6:
		li a0, 10
		li a7, 32 
		ecall		#Pause for 100 milisec
		
		li t0, KEY_STATUS_ADDRESS
		beq t0, zero, .reset_wait_6
		j .reset_6
	
	.reset_6:
		sw zero, p1_score, t0
		sw zero, p2_score, t0
		jal clear_key_status
		jal clear_key_press
		jal clear_board
		j Level_1
		
	lw ra, 0(sp)
	addi sp, sp, 4
	
	jr ra 
draw_destructible_3:

#a0 = x
#a1 = y

    addi sp, sp, -4
    sw ra, 0(sp)
    
    lw a2, color_lblue
    addi a0, zero, 15
    addi a1, zero, 17
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 15
    addi a1, zero, 18
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################
    
    lw a2, color_lblue
    addi a0, zero, 26
    addi a1, zero, 22
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 26
    addi a1, zero, 23
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################

    lw a2, color_lblue
    addi a0, zero, 11
    addi a1, zero, 5
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 11
    addi a1, zero, 6
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################
    
    lw a2, color_lblue
    addi a0, zero, 15
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 15
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################
    
    lw a2, color_lblue
    addi a0, zero, 21
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 21
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line   
    
    ######################### 
    
    lw a2, color_lblue
    addi a0, zero, 35
    addi a1, zero, 18
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 35
    addi a1, zero, 19
    addi a3, a0, 1
    jal draw_horizontal_line  
    
    ######################### 
    
    lw a2, color_lblue
    addi a0, zero, 35
    addi a1, zero, 14
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 35
    addi a1, zero, 15
    addi a3, a0, 1
    jal draw_horizontal_line 
    
    ######################### 
   
    lw a2, color_lblue
    addi a0, zero, 19
    addi a1, zero, 17
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 19
    addi a1, zero, 18
    addi a3, a0, 1
    jal draw_horizontal_line 
    
    ######################### 
    
    lw a2, color_lblue
    addi a0, zero, 35
    addi a1, zero, 26
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 35
    addi a1, zero, 27
    addi a3, a0, 1
    jal draw_horizontal_line 
    
    #########################
    
    lw a2, color_lblue
    addi a0, zero, 4
    addi a1, zero, 9
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 4
    addi a1, zero, 10
    addi a3, a0, 1
    jal draw_horizontal_line 
    
    #########################
    
    lw a2, color_lblue
    addi a0, zero, 18
    addi a1, zero, 23
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 18
    addi a1, zero, 24
    addi a3, a0, 1
    jal draw_horizontal_line 
    
    #########################
    
    lw a2, color_lblue
    addi a0, zero, 11
    addi a1, zero, 8
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 11
    addi a1, zero, 9
    addi a3, a0, 1
    jal draw_horizontal_line 
    
    #########################
    
    lw a2, color_lblue
    addi a0, zero, 18
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 18
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_lblue
    addi a0, zero, 42
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 42
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line

    #########################  
    
    lw a2, color_lblue
    addi a0, zero, 47
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 47
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line

    #########################  
    
    lw a2, color_lblue
    addi a0, zero, 54
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 54
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line
    
    ########################  
    
    lw a2, color_lblue
    addi a0, zero, 57
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 57
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_lblue
    addi a0, zero, 51
    addi a1, zero, 14
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 51
    addi a1, zero, 15
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_lblue
    addi a0, zero, 51
    addi a1, zero, 7
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 51
    addi a1, zero, 8
    addi a3, a0, 1
    jal draw_horizontal_line
   
    #########################  
    
    lw a2, color_lblue
    addi a0, zero, 26
    addi a1, zero, 11
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 26
    addi a1, zero, 12
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_lblue
    addi a0, zero, 26
    addi a1, zero, 26
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 26
    addi a1, zero, 27
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_lblue
    addi a0, zero, 11
    addi a1, zero, 14
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 11
    addi a1, zero, 15
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_lblue
    addi a0, zero, 51
    addi a1, zero, 26
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 51
    addi a1, zero, 27
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_lblue
    addi a0, zero, 51
    addi a1, zero, 23
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 51
    addi a1, zero, 24
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_lblue
    addi a0, zero, 48
    addi a1, zero, 23
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 48
    addi a1, zero, 24
    addi a3, a0, 1
    jal draw_horizontal_line
    
    #########################  
    
    lw a2, color_lblue
    addi a0, zero, 47
    addi a1, zero, 17
    addi a3, a0, 1
    jal draw_horizontal_line
    
    lw a2, color_lblue
    addi a0, zero, 47
    addi a1, zero, 18
    addi a3, a0, 1
    jal draw_horizontal_line


    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra
	
# Function: clear_key_press
# Parameters:
# 	none.
# Return:
#	void.
clear_key_press:
	sw zero, KEY_INPUT_ADDRESS, t0
	jr ra
	
# Function: clear_key_status
# Parameters:
# 	none.
# Return:
#	void.
clear_key_status:
	sw zero, KEY_STATUS_ADDRESS, t0
	jr ra


end:

j end

