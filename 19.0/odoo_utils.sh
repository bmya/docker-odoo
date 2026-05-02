#!/bin/bash

# Script de utilitarios para Odoo

case "$1" in
  restart)
    echo "Reiniciando Odoo..."
    pkill -f odoo
    sleep 2
    /mnt/odoo/odoo-bin --config=/etc/odoo/odoo.conf &
    echo "Odoo reiniciado."
    ;;
  status)
    echo "Estado de Odoo:"
    ps aux | grep odoo | grep -v grep
    ;;
  logs)
    echo "Mostrando logs de Odoo..."
    tail -n 50 /var/log/odoo/odoo.log 2>/dev/null || echo "Logs no disponibles en /var/log/odoo/odoo.log"
    ;;
  test_barcode)
    echo "Probando generación de código de barras..."
    cd /tmp
    python3 -c "from reportlab.graphics.barcode import createBarcodeDrawing; from reportlab.graphics import renderPM; d = createBarcodeDrawing('Extended39', value='TEST', width=200, height=100); renderPM.drawToFile(d, 'test.png', 'PNG')"
    ls -l /tmp/test.png
    ;;
  test_pdf417)
    echo "Probando pdf417gen..."
    cd /tmp
    python3 -c "from pdf417gen import encode, render_image; codes = encode('TEST', columns=10, security_level=0); img = render_image(codes); img.save('test_pdf417.png')"
    ls -l /tmp/test_pdf417.png
    ;;
  *)
    echo "Uso: $0 {restart|status|logs|test_barcode|test_pdf417}"
    exit 1
    ;;
esac
