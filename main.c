#include <VTL/VTL.h>


int main(void)
{
    VTL_AppResult app_result = VTL_PubicateMarkedText("text.md", VTL_CONTENT_PLATFORM_W | VTL_CONTENT_PLATFORM_TG, VTL_markup_type_kTelegramMD);
    VTL_console_out_PotencialErr(app_result);
    return app_result;
}