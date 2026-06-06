package com.ihm.service;

import com.ihm.exception.ResourceNotFoundException;
import com.ihm.repository.*;
import com.ihm.model.*;
import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.imageio.ImageIO;
import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.text.NumberFormat;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;

@Service
public class PDFTicketService {

    private static final Logger log = LoggerFactory.getLogger(PDFTicketService.class);

    private final TicketRepository ticketRepository;
    private final ConcernerRepository concernerRepository;
    private final CorrespondARepository correspondARepository;
    private final QRCodeService qrCodeService;
    private final EvenementPlaceConfigurationRepository configRepository;

    public PDFTicketService(TicketRepository ticketRepository,
                            ConcernerRepository concernerRepository,
                            CorrespondARepository correspondARepository,
                            QRCodeService qrCodeService,
                            EvenementPlaceConfigurationRepository configRepository) {
        this.ticketRepository = ticketRepository;
        this.concernerRepository = concernerRepository;
        this.correspondARepository = correspondARepository;
        this.qrCodeService = qrCodeService;
        this.configRepository = configRepository;
    }

    // generation du PDF d'un ticket
    @Transactional(readOnly = true)
    public byte[] generateTicketPDF(String codeTicket) {
        log.debug("Generating PDF for ticket: {}", codeTicket);
        Ticket ticket = ticketRepository.findByCodeTicket(codeTicket)
                .orElseThrow(() -> new ResourceNotFoundException("Ticket", "codeTicket", codeTicket));

        List<Concerner> concerners = concernerRepository.findByTicket_CodeTicket(codeTicket);
        if (concerners.isEmpty()) {
            throw new ResourceNotFoundException("Concerner", "codeTicket", codeTicket);
        }
        Concerner concerner = concerners.get(0);
        Place place = concerner.getPlace();
        Evenement evenement = concerner.getEvenement();

        List<CorrespondA> correspondances = correspondARepository.findByTicket_CodeTicket(codeTicket);
        String clientNom = "";
        if (!correspondances.isEmpty()) {
            clientNom = correspondances.get(0).getReservation().getClient().getNom() + " " +
                    correspondances.get(0).getReservation().getClient().getPrenoms();
        }

        String qrData = qrCodeService.generateTicketData(codeTicket, evenement.getTitre(), place.getNumeroPlace());
        String qrBase64 = qrCodeService.generateQRCodeBase64(qrData);

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try {
            Document document = new Document(PageSize.A5);
            PdfWriter.getInstance(document, baos);
            document.open();

            Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18, new Color(33, 37, 41));
            Font subtitleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14, new Color(73, 80, 87));
            Font labelFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, new Color(108, 117, 125));
            Font valueFont = FontFactory.getFont(FontFactory.HELVETICA, 11, new Color(33, 37, 41));

            Paragraph title = new Paragraph("TICKET D'ENTREE", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            title.setSpacingAfter(4);
            document.add(title);

            Paragraph reference = new Paragraph("Ref: " + codeTicket, subtitleFont);
            reference.setAlignment(Element.ALIGN_CENTER);
            reference.setSpacingAfter(15);
            document.add(reference);

            PdfPTable table = new PdfPTable(2);
            table.setWidthPercentage(100);
            table.setSpacingAfter(12);
            table.setWidths(new float[]{1, 2});

            addRow(table, "Evenement", evenement.getTitre(), labelFont, valueFont);
            addRow(table, "Date", evenement.getDateEvenement().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")), labelFont, valueFont);
            if (evenement.getHeureEvenement() != null) {
                addRow(table, "Heure", evenement.getHeureEvenement().format(DateTimeFormatter.ofPattern("HH:mm")), labelFont, valueFont);
            }
            addRow(table, "Lieu", evenement.getLieu() != null ? evenement.getLieu().getNomLieu() : "-", labelFont, valueFont);
            addRow(table, "Siege", place.getNumeroPlace(), labelFont, valueFont);
            EvenementPlaceConfiguration pdfConfig = configRepository
                    .findByEvenement_IdEvenementAndPlace_NumeroPlace(evenement.getIdEvenement(), place.getNumeroPlace())
                    .orElse(null);
            String rangee = pdfConfig != null && pdfConfig.getRange() != null ? pdfConfig.getRange() : "-";
            String type = pdfConfig != null && pdfConfig.getTypePlace() != null ? pdfConfig.getTypePlace() : "-";
            addRow(table, "Rangee", rangee, labelFont, valueFont);
            addRow(table, "Type", type, labelFont, valueFont);
            if (!clientNom.isEmpty()) {
                addRow(table, "Client", clientNom, labelFont, valueFont);
            }
            addRow(table, "Prix", ticket.getPrix() != null
                    ? NumberFormat.getCurrencyInstance(Locale.FRANCE).format(ticket.getPrix()) : "0,00 €", labelFont, valueFont);

            document.add(table);

            ByteArrayOutputStream qrBytes = new ByteArrayOutputStream();
            ImageIO.write(qrCodeService.decodeBase64ToBufferedImage(qrBase64), "PNG", qrBytes);
            Image qrImage = Image.getInstance(qrBytes.toByteArray());
            qrImage.setAlignment(Element.ALIGN_CENTER);
            qrImage.scaleToFit(120, 120);
            qrImage.setSpacingBefore(8);
            document.add(qrImage);

            Paragraph footer = new Paragraph("Presentez ce QR code a l'entree",
                    FontFactory.getFont(FontFactory.HELVETICA_OBLIQUE, 9, new Color(108, 117, 125)));
            footer.setAlignment(Element.ALIGN_CENTER);
            footer.setSpacingBefore(8);
            document.add(footer);

            Paragraph status = new Paragraph("Statut: VALIDE",
                    FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11, new Color(40, 167, 69)));
            status.setAlignment(Element.ALIGN_CENTER);
            status.setSpacingBefore(4);
            document.add(status);

            document.close();
        } catch (DocumentException | IOException e) {
            log.error("Error: {}", e.getMessage());
            throw new RuntimeException("Failed to generate ticket PDF", e);
        }

        return baos.toByteArray();
    }

    private void addRow(PdfPTable table, String label, String value, Font labelFont, Font valueFont) {
        PdfPCell labelCell = new PdfPCell(new Phrase(label, labelFont));
        labelCell.setBorder(Rectangle.NO_BORDER);
        labelCell.setPadding(3);
        labelCell.setVerticalAlignment(Element.ALIGN_MIDDLE);

        PdfPCell valueCell = new PdfPCell(new Phrase(value, valueFont));
        valueCell.setBorder(Rectangle.NO_BORDER);
        valueCell.setPadding(3);
        valueCell.setVerticalAlignment(Element.ALIGN_MIDDLE);

        table.addCell(labelCell);
        table.addCell(valueCell);
    }
}
