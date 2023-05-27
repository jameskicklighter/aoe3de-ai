# aoe3de-ai
Ongoing AI Mod for Age of Empires 3 Definitive Edition.
MOD LINK: https://www.ageofempires.com/mods/details/19188/

I began working on this mod in October 2020 shortly after the release of Age of Empires III: Definitive Edition. I work to try to improve many aspects of the AI, and while there is a great degree of freedom in adding new AI strategy and functionality, some things are still limited by the source code functions that are unchangeable except for the developers.

Thus far, most changes I have made work to improve the economical side of the AI. With the release of the Definitive Edition, good military micro (for AI) was added by the developers hardcoded, accessible only via a function that turns these micro capabilities on or off. However, the default gather plans needed some improvement. The default gathering methods are hardcoded via several functions, but I used some workaround commands and queries to completely rewrite the AI gathering system. I used a similar, heavily inspired framework from Panmaster's ZenMasterAI (a mod for the vanilla Age of Empires 3 franchise) and began to work from there. It allowed me to directly control what the settlers do. There are some drawbacks I have encountered, but I still think my changes are a net positive in terms of efficiency.

Another aspect I reworked is the shipment system. Once you understand the basics of the code, this isn't too hard. However, it can be tricky when you try to account for multiple different possibilities before sending a shipment. The rather arbitrary scoring system seemed lackluster, so I implemented a queue of sorts that the AI will check and try to send various cards if certain conditions are met (if there should be any conditions attached to the card).
I have made various other improvements, but there is still much work to do.
