#include <tice.h>
#include <graphx.h>
#include <keypadc.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
static uint8_t line_guard[4096],buffer_guard[4096];
volatile uint8_t text_diag[8]; /* done,dialogue_overflow,help_overflow,stress_overflow,real_bad_coords,stress_bad_coords,pagecount,buffer_overflow */
static int bad_coords;
static void capture_print(const char*s,int x,int y){if(x<0||y<0||x+(int)gfx_GetStringWidth(s)>320||y+8>240)bad_coords++;}
#define gfx_PrintStringXY capture_print
void print_fit(const char *s, int x, int y) {
    if (!s || y < 0 || y > 232 || x > 315) return;
    if (x < 0) x = 0;
    if (x + (int)gfx_GetStringWidth(s) <= 316) { gfx_PrintStringXY(s, x, y); return; }
    char *buffer=(char *)buffer_guard+128;memset(buffer,0,96); int n = 0;
    while (s[n] && n < 90) { buffer[n] = s[n]; buffer[n + 1] = 0; if (x + (int)gfx_GetStringWidth(buffer) > 316) { buffer[n] = 0; break; } n++; }
    gfx_PrintStringXY(buffer, x, y);
}
void center_text(int y, const char *s) { int w = gfx_GetStringWidth(s); print_fit(s, w >= 316 ? 2 : (320 - w) / 2, y); }
void wrap_text(int x, int y, int width, const char *s, int step) {
    char *line=(char *)line_guard+128; int n = 0;
    if (!s || width <= 0 || step <= 0) return;
    while (*s && y <= 232) {
        if (*s == '\n') { line[n] = 0; print_fit(line, x, y); n = 0; y += step; s++; continue; }
        if (*s == ' ') { if (n && n < 90) line[n++] = ' '; s++; continue; }
        int len = 0; while (s[len] && s[len] != ' ' && s[len] != '\n') len++;
        if (len > 40) len = 40;
        /* Check capacity before copying: a narrow-font line can contain many
         * characters even when it still fits the requested pixel width. */
        if (n + len >= (int)96) {
            line[n] = 0; print_fit(line, x, y); y += step; n = 0;
            if (y > 232) break;
        }
        memcpy(line + n, s, len); line[n + len] = 0;
        if (n && (int)gfx_GetStringWidth(line) > width) {
            while (n && line[n - 1] == ' ') n--;
            line[n] = 0; print_fit(line, x, y); y += step; memcpy(line, s, len); n = len; line[n] = 0;
        } else n += len;
        s += len;
    }
    line[n] = 0; if (n) print_fit(line, x, y);
}
#undef gfx_PrintStringXY
static int corrupted(const uint8_t*a){for(int i=0;i<4096;i++)if((i<128||i>=224)&&a[i]!=0xa5)return 1;return 0;}
static void clear_guards(void){memset(line_guard,0xa5,sizeof line_guard);memset(buffer_guard,0xa5,sizeof buffer_guard);}
static const char *pages[]={"You have trespassed on the ancient lands of the Yak Clan!  You shall be destroyed!","Ooh... would you mind if I just passed through? I've lost a bunch of mail, and I just need to pick it up.","NEVER!!!!!!","Brrrr... I knew it was a mistake to fly the blimp in my pajamas! Crashing it wasn't great either.","Boy, the boss is gonna kill me... I better make my way to the wreck and find all the fan mail!","I have carefully ensconced this artifact from the sky in my Precious Things vault! You may not have it!","But that's a fan letter to Boys' Life!  Look at it!  It's not addressed to you!","Your symbols mean nothing to me, even though I clearly speak English!  Begone!","Wow... I guess she's not flying again. On the plus side, the wreckage is arranged in nice neat platforms!","We are the Ninja Brothers! We are visiting from Japan! Let us engage in the local custom of pummeling you!","Really?  This is what we're doing now?","You have shown great power, strange burro. But your journey ends here. No stranger may enter the Ancient Temple of the Yak Clan!","As much as I'd like to take a break, I have a sworn duty to deliver the Boys' Life fan mail!","And as much as I admire your tenacity, I'm afraid the letters are far too interesting. We shall keep them.","What?  Oh come on!  Those are our letters! Hand them over!","I think I will go read some right now. You can discuss the matter further with Torgo. Good day!","Puny burro! You cannot scale the mighty walls of the Yak Clan Temple! I shall use you for target practice!","Hmm... that is quite a wall. I better find another way in!","Gulp.","Alright, donkey! You think you're so tough? Face my Gauntlet of Death!","Your skills are most impressive. But now I have built a Mighty Robot to destroy you! I'm quite good with my hands.","Wait, did you just stick a trashcan on Torgo's head?",". . . .","BEEP BOOP","Yes.","You know, this is getting ridiculous. I'm half-tempted to not even offer bonus rewards in this Gauntlet of Death!","Alright, that's IT!  Hand over the mail so I can go home!","Boy, with you around, I'm glad I have these Barrier Orbs making me invincible!"};
int main(void){gfx_Begin();gfx_SetDrawBuffer();gfx_SetTextScale(1,1);uint16_t white=0x7fff,black=0;gfx_SetPalette(&white,2,255);gfx_SetPalette(&black,2,0);gfx_SetTextTransparentColor(0);gfx_SetTextBGColor(0);
 for(unsigned i=0;i<sizeof pages/sizeof pages[0];i++){clear_guards();wrap_text(23,47,274,pages[i],11);text_diag[1]+=corrupted(line_guard);text_diag[7]+=corrupted(buffer_guard);}
 clear_guards();wrap_text(8,20,304,"Arrows: run; hold Down to duck; double-tap a direction for Burro Bash.\nUp or 2nd: jump.\nAlpha: punch; in the air, kick; duck + Alpha: Pedroken; Down in the air: dive kick; hold Alpha after a Burro Bash hit to grab.\nDel: Fury. With a full bar, hold Del and press Down (blast), Left (freeze), Right (frenzy) or Up (fix).\nMODE: pause. STAT: skills. CLEAR: save and quit.\nCollect all the lost mail to finish a stage. Find Ancient Techniques, hearts and Fury Souls; level up for skill points.",11);text_diag[2]=corrupted(line_guard);text_diag[4]=bad_coords;text_diag[7]+=corrupted(buffer_guard);
 clear_guards();bad_coords=0;char stress[500];for(int i=0;i<490;i++)stress[i]=i%11==10?' ':'i';stress[490]=0;wrap_text(8,20,304,stress,11);text_diag[3]=corrupted(line_guard);text_diag[5]=bad_coords;text_diag[7]+=corrupted(buffer_guard);text_diag[6]=sizeof pages/sizeof pages[0];text_diag[0]=1;
 gfx_FillScreen(0);gfx_SetTextFGColor(255);char text[40];gfx_PrintStringXY("PDTEXT native text diagnostics",8,12);for(int i=0;i<8;i++){snprintf(text,sizeof text,"%d: %d",i,text_diag[i]);gfx_PrintStringXY(text,12,35+i*18);}gfx_SwapDraw();while(1){kb_Scan();if(kb_Data[6]&kb_Clear)break;}gfx_End();return 0;}
