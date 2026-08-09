package com.toeic.practice.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.view.RedirectView;

@RestController
@RequestMapping("/api/media")
@ConditionalOnProperty(name = "media.strategy", havingValue = "drive")
public class MediaController {

    @GetMapping("/**")
    public RedirectView redirectMedia(HttpServletRequest request) {
        String fullPath = request.getRequestURI();
        // Lấy đường dẫn file, ví dụ: audio/test1/part1/1.mp3
        String mediaPath = fullPath.substring("/api/media/".length());
        
        // TODO: Đọc mapping từ file JSON (mediaPath -> Google Drive File ID)
        // Hiện tại trả về một ID giả định để demo logic redirect
        String mockFileId = getDriveFileIdByPath(mediaPath);
        
        return new RedirectView("https://drive.google.com/uc?export=download&id=" + mockFileId);
    }
    
    private String getDriveFileIdByPath(String path) {
        // Map các file thường dùng hoặc return default
        // Cần triển khai đọc từ drive_mapping.json trong thực tế
        return "1ABCDEFGHIJKLMN_mock_id_for_" + path.replace("/", "_").replace(".", "_");
    }
}
