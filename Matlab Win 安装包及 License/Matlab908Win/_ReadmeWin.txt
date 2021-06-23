0. Смонтируйте iso-образ Matlab98R2020a_Win64.iso в виртуальный диск.
     На виндовз 8 и ниже для этого может потребоваться программа типа Daemon Tools Lite (или любая подобная)
1. Запустите setup.exe на этом виртуальном диске и если вы видите запрос логина Mathworks (т.е. если вы дали доступ в интернет установщику)
     то в правом верхнем углу в "Advanced Options" выберите режим установки "I have a File Installation Key"
     Если доступа в интернет установщик не обнаружит, то требуемый режим установки будет выбран автоматом
2. Когда дойдете до "Enter File Installation Key" введите
     09806-07443-53955-64350-21751-41297
3. Когда дойдете до "Select License File" выберите файл license.lic
4. Далее выбирайте папку куда хотите поставить Матлаб (<matlabfolder>) и когда дойдете до "Select products" снимите галку с
     "Matlab Parallel Server" и оставьте галки на нужных вам компонентах.
     Если будет выбрано всё, то Матлаб займет 32Гига. Если только "MATLAB" то 3Гига
     Поэтому для экономии места и времени запуска отключайте то что вы не знаете и вам не нужно.
     Матлаб лучше ставить на SSD диск для повышения скорости запуска (а такие диски зачастую "не резиновые"). Так что думайте сами.
5. Когда дойдете до "Select Options" выберите галочку "Add shortcut to desktop"
6. Прогресс установки компонентов может не отображаться корректно (например, всегда показывать 0%) ... просто ждите.
     Если процесс затянулся слишком долго следите растет ли размер папки куда ставите Матлаб.
     Если несколько минут размер не растет - перезапустите установку
7. По окончании установки скопируйте файл "libmwlmgrimpl.dll" в уже существующую папку
     "<matlabfolder>\bin\win64\matlab_startup_plugins\lmgrimpl"
     с перезаписью уже существующего файла, где <matlabfolder> - папка куда вы поставили Матлаб
8. Скопируйте файл "license.lic" в папку "<matlabfolder>\licenses" (создайте папку licenses если ее нету)
     Альтернативно, можете не копируя файл лицензии сразу запустить Матлаб.
     В этом случае получите окно, где сможете выбрать файл лицензии через интерфейс пользователя:
       Выбирайте опцию "Activate manually without the Internet" and
       А в поле "Enter the full path to your license file, including the file name" выбирайте файл "license.lic" file
9. Можно работать :)
     Если установщик по ходу процесса завис где-то на 1-6 шаге то принудительно закройте установщик и начните заново с шага 1


P.S.
Кому интересно, license.lic в дополнение к возможностям license_standalone.lic позволяет использовать Матлаб через удаленный рабочий стол (RDP), т.е.
  позволяет в некоторых случаях не использовать license_server.lic

P.S.2
На самом деле File Installation Key зависит от редакции Матлаба и типа применяемой лицензии
  Для локальной лицензии используйте license.lic или license_standalone.lic и ключи:
    Для рабочей станции (типичная конфигурация) : 09806-07443-53955-64350-21751-41297
    Для узла кластера "Matlab Parallel Server"  : 40236-45817-26714-51426-39281
  Для плавающей лицензии используйте license_server.lic и ключи:
    Для рабочей станции (типичная конфигурация) : 31095-30030-55416-47440-21946-54205
    Для узла кластера "Matlab Parallel Server"  : 57726-51709-20682-42954-31195



0. Mount iso-file Matlab98R2020a_Win64.iso to virtual disk.
     For Windows 8 and lower you probably need soft like Daemon Tools Lite (or similar)
1. Run setup.exe from that virtual disk and if you see login/password/signin form (you gave access to internet for installer)
     then in apper left corner in "Advanced Options" select setup mode "I have a File Installation Key"
     If internet access is absent then required setup mode will be autoselected and you do not need to set setup mode
2. When you will be asked to "Enter File Installation Key" enter
     09806-07443-53955-64350-21751-41297
3. When you will be asked to "Select License File" select license.lic
4. Then select folder where you want Matlab to be installed. When you will be asked to "Select products" deselect component
     "Matlab Parallel Server" and select components you need.
     If you will leave all components selected matlab will need 32Gb of disk space and longer startup time.
     If you left only "MATLAB" - 3Gb of disk space
     You better setup matlab on SSD disk for better startup time, so most likely you do not want to waste SSD-disk size for nothing.
5. Then in "Select Options" select "Add shortcut to desktop"
6. Components setup progress may be shown incorrectly (for example allways show 0%) ... just wait.
     Or if installation process takes too long start to monitor growth size of folder where you are installing matlab
     If it size is not growing several minutes then restart setup
7. After installation is done copy file "libmwlmgrimpl.dll" to already existing folder
     "<matlabfolder>\bin\win64\matlab_startup_plugins\lmgrimpl"
     with overwriting of existing file (<matlabfolder> - is where you have installed Matlab)
8. Copy "license.lic" file to <matlabfolder>\licenses folder
     Alternatively you can just start Matlab. In that case you will got window asking you to select license
       First select "Activate manually without the Internet" and
       then in field "Enter the full path to your license file, including the file name" select "license.lic" file
9. Work with matlab :)
     If setup hang in step 1-6 then force to close setup and start again from step 1

P.S.
license.lic additionally to possibilities of license_standalone.lic gives Matlab permission to work from remote desktop (RDP)
  This allow not to use license_server.lic in certain cases

P.S.2
File Installation Key you give to installer actually depend on Matlab edition and type of license you want
  For standalone license use license.lic or license_standalone.lic and keys:
    For workstation use case (typical configuration) : 09806-07443-53955-64350-21751-41297
    For cluster node "Matlab Parallel Server"        : 40236-45817-26714-51426-39281
  For floating license use license_server.lic and keys:
    For workstation use case (typical configuration) : 31095-30030-55416-47440-21946-54205
    For cluster node "Matlab Parallel Server"        : 57726-51709-20682-42954-31195
