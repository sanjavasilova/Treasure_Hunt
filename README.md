# Имплементација на Играта
## Опис на Играта
Играта "Treasure Hunt" е 3D игра во која играчот се движи низ парк во потрага по скриени богатства. Играчот може да се движи, да скока преку пречки и да собира различни предмети распоредени низ околината. Целта на играта е да се пронајдат сите скриени богатства пред да истече времето.

## Карактеристики на играта:
### Движење на играчот
**Контроли:** Играчот се контролира со тастатурата:  
&emsp;W: Движење напред.  
&emsp;A: Движење налево.  
&emsp;S: Движење назад.  
&emsp;D: Движење надесно.  
&emsp;Space: Скокање.  
**Детали:**  
Играчот е физички објект (RigidBody3D) што реагира на гравитација и судири. И движењето на истиот е релативно во однос на ротацијата на играчот, што значи дека играчот секогаш се движи во насоката во која гледа. Скокањето е овозможено само ако играчот е на земја (се проверува со _integrate_forces). Камерата се ротира со движење на глувчето, што овозможува играчот да гледа наоколу.

### Собирање на богатства
**Ковчези:** Ковчезите се објекти распоредени низ паркот.  
**Механика:**  
Кога играчот ќе се судри со ковчегот (преку Area3D), ковчегот исчезнува. Притоа, секој ковчег додава поени на резултатот на играчот. Ковчезите се инстанцирани на случајни позиции, но се осигурува дека не се преклопуваат со други објекти или ковчези.  
**Сигнали:** Кога ковчегот е собран, се емитува сигнал (chest_collected) кој го ажурира резултатот на играчот.

### Околина на паркот
**Објекти:** Паркот содржи различни 3D објекти, вклучувајќи:  
&emsp;Дрвја: Статични објекти кои служат како препреки или декорација.  
&emsp;Клупи: Места за одмор, кои исто така можат да бидат препреки.  
&emsp;Фонтана: Централен елемент на паркот, со анимација на вода.  
&emsp;Црквичка/Куќичка: Мали структури кои ја збогатуваат атмосферата.  
**Препреки:** Некои објекти се препреки кои играчот мора да ги заобиколи или да скокне преку нив.

### Тајмер
**Одбројување:** Играта има ограничено време за собирање на сите ковчези.
**Механика:** Тајмерот започнува од дефинирано време (120 секунди) и одбројува наназад. Времето се прикажува на екранот во формат MM:SS, ако времето истече пред да се соберат сите ковчези, играта завршува.  
**Интеракција:** Играчот мора да управува со времето и да ги приоритизира ковчезите за да ги собере сите навреме.

### Екран за победа/пораз
**Победа:** Ако играчот ги собере сите ковчези пред да истече времето, се прикажува пораката "You won! You collected all the chests". Играчот може да ја рестартира играта со клик на копчето "Play Again?".  
**Пораз:** Ако времето истече пред да се соберат сите ковчези, се прикажува пораката "Time's up!". Исто така, се прикажува копчето "Play Again?" за рестарт.  
**UI Елементи:**
&emsp;ScoreLabel: Го прикажува бројот на собрани ковчези (на пр. "Chests: 3/10").  
&emsp;TimerLabel: Го прикажува преостанатото време (на пр. "Time Left: 01:30").  
&emsp;GameOverLabel: Го прикажува крајниот резултат ("You won! You collected all the chests" или "Time's up!").  
&emsp;TryAgainButton: Копче за рестарт на играта.

### Дополнителни карактеристики
**Анимации:** Играчот има анимации за одење (Walking0) и мирување (Idle0). Анимациите се менуваат автоматски врз основа на движењето на играчот.
**Рестарт на играта:** Играта може да се рестартира без да се излезе од главното мени, што го подобрува корисничкото искуство.  
**Звук:** Играта има музика во позадина и при собирање на ковчег се пушта друг звук.  

## Имплементација на Кодот
### player.gd
**_ready()**  
***Цел:*** Иницијализација на играчот при стартување на сцената.  
***Детали:***  
&emsp;Го прикачува глувчето во центарот на екранот (Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED).  
&emsp;Го додава играчот во групата "player" за лесно идентификување.  
&emsp;Го стартува анимационото дрво на играчот (на пр., "Idle0" анимација) за да се избегне T-Pose (стандардна позиција без анимација).

**_integrate_forces(state)**  
***Цел:*** Проверка дали играчот е на земја.  
***Детали:***  
&emsp;Ја проверува физичката состојба на играчот (state) и ги анализира контактите со други тела.  
&emsp;Ако нормалата на контакт е насочена нагоре (.dot(Vector3.UP) > 0.5), играчот е на земја.  

**_process(delta)**  
***Цел:*** Контрола на движењето, скокањето и анимациите на играчот.  
***Детали:***  
&emsp;Го чита влезот од тастатурата (WASD) за движење.  
&emsp;Го ротира играчот налево/надесно врз основа на влезот.  
&emsp;Го пресметува векторот на движење (move_direction) врз основа на ротацијата на играчот.  
&emsp;Го применува движењето со сила (apply_central_force).  
&emsp;Овозможува скокање (apply_impulse) ако играчот е на земја.  
&emsp;Го контролира движењето на камерата (twist_pivot и pitch_pivot).  
&emsp;Ги менува анимациите помеѓу "Walking0" и "Idle0" врз основа на движењето.  

**_unhandled_input(event)**  
***Цел:*** Ротација на камерата со движење на глувчето.  
***Детали:***  
&emsp;Го ротира играчот налево/надесно (rotate_y) и камерата нагоре/надолу (pitch_pivot.rotate_x).  
&emsp;Го ограничува аголот на камерата за да се избегне преголемо ротирање.

### treasure_chest.gd
**_ready()**  
***Цел:*** Иницијализација на ковчегот.  
***Детали:***  
&emsp;Ја поставува текстурата на ковчегот (chest_texture).  
&emsp;Го поврзува сигналот body_entered од Area3D со функцијата _on_body_entered.

**_on_body_entered(body)**  
***Цел:*** Се активира кога играчот ќе се судри со ковчегот.  
***Детали:*** Проверува дали телото што се судрило е играч (body.is_in_group("player")). Ако е, го емитува сигналот chest_collected и го брише ковчегот од сцената (queue_free).

### treasure_spawn.gd
**_ready()**  
***Цел:*** Иницијализација на играта.  
***Детали:***  
&emsp;Го иницијализира тајмерот (Timer) и го стартува одбројувањето.  
&emsp;Го поставува почетниот текст на UI елементите (score_label, timer_label).  
&emsp;Го крие екранот за крај на играта (game_over_label и try_again_button).  
&emsp;Го повикува spawn_chests() за да ги создаде ковчезите.  

**spawn_chests()**  
***Цел:*** Создавање на ковчезите на случајни позиции.  
***Детали:***  
&emsp;Се обидува да создаде ковчези на случајни позиции (get_random_position).  
&emsp;Проверува дали позицијата е слободна (is_position_free).  
&emsp;Ако е слободна, го инстанцира ковчегот и го додава во сцената.  

**get_random_position()**  
***Цел:*** Генерирање на случајна позиција во дефинираната област.  
***Детали:***  
&emsp;Генерира случајни координати (random_x, random_z) во рамките на spawn_area_size.  
&emsp;Ја враќа позицијата како Vector3.  

**is_position_free(pos, spawned_positions)**  
***Цел:*** Проверка дали позицијата е слободна.  
***Детали:***  
&emsp;Проверува дали позицијата е доволно далеку од другите ковчези.  
&emsp;Користи физичка проверка (PhysicsShapeQueryParameters3D) за да се осигура дека нема преклопување со други објекти.  

**_on_chest_collected()**  
***Цел:*** Се активира кога ковчегот е собран.  
***Детали:***  
&emsp;Го зголемува бројот на собрани ковчези (collected_chests).  
&emsp;Го ажурира текстот на score_label.  
&emsp;Ако сите ковчези се собрани, ја завршува играта со порака "YOU WON! You collected all the chests!".  

**_on_timer_timeout()**  
***Цел:*** Се активира кога тајмерот истекува.  
***Детали:*** Ја завршува играта со порака "Time's up!".  

**end_game(message)**  
***Цел:*** Прикажување на екранот за крај на играта.  
***Детали:***  
&emsp;Го прикажува текстот на game_over_label.  
&emsp;Го прикажува копчето "Play Again?".  
&emsp;Ја паузира играта (get_tree().paused = true).  

### ui.gd
**_ready()**  
***Цел:*** Иницијализација на UI елементите.  
***Детали:***  
&emsp;Го поставува почетниот текст на score_label и timer_label.  
&emsp;Го крие екранот за крај на играта (game_over_label и try_again_button).  
&emsp;Го поврзува сигналот pressed на try_again_button со функцијата _on_try_again_pressed.  

**_on_try_again_pressed()**  
***Цел:*** Се активира кога играчот ќе кликне на "Play Again?".  
***Детали:***  
&emsp;Ја рестартира сцената (get_tree().change_scene_to_file).  
&emsp;Го продолжува играта (get_tree().paused = false).  

## Слики од Играта
###	Почетен Екран:
![Beginning screen](Game_Images/game%20pic.jpg)

### Играч
![Player](Game_Images/character.jpg)  

###	Играње:
Играчот се движи низ паркот и собира ковчези.

![Collecting chests](Game_Images/game%20pic%204.jpg)
![Walking through the park](Game_Images/game%20pic%202.jpg)
![Walking through the park](Game_Images/game%20pic%203.jpg)
###	Крај на Играта:
Победа

![Win](Game_Images/game%20pic%206.jpg)
Пораз

![Lost](Game_Images/game%20pic%205.jpg)

## Линк до видеото

[Treasure hunt video play](https://youtu.be/j0llFst2jlo)

## Заклучок
Играта е едноставна, но забавна 3D игра која ги користи основните принципи на движење, ротација и интеракција. Со помош на Godot Engine и GDScript, играта е лесно имплементирана и може да се прошири со дополнителни функционалности.

