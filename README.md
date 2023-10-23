# varGroup
The task:
Написать скрипт назначения пермишенов для группы переменных Azure Devops по маске. Например , назначить права администратора пользователю test@testdomain.com для всех групп переменных АжурДевопс содержащих слово "front" (в любом регистре).
Реализация на любом языке, максимально гибкое решение чтоб было и без лишних кастомных плагинов. желательно, например, через пайплайн в ажур девопс или ещё чем-то, красиво и быстро. На входе указать маску и кому (или группу пользователей).


You need to create PAT token to authenticate to Azure DevOps API. 
In this example PAT token added to "DEV_VAR_GROUP" Variable Group, change accordingly.
