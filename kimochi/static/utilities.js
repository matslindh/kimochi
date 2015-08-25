function flash_button_ok (element) {
    element.blur();

    element.animate({
        backgroundColor: "#aaffaa",
        borderColor: "#ccc",
        color: "#000000",
    }, 300, function () {
        $(this).delay(1000).animate({
            backgroundColor: "#ffffff",
        }, 300, function () {
            $(this).removeClass('btn-primary');
            $(this).removeAttr('style');
        });
    });
}