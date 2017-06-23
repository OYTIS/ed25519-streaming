#include <stdio.h>
#include <stdlib.h>
#include "edsign.h"

// main <public_key_in_hex> <signature_in_hex> /path/to/message
int main(int argc, const char** argv)
{
	uint8_t signature[EDSIGN_SIGNATURE_SIZE];
	uint8_t public[EDSIGN_PUBLIC_KEY_SIZE];
	
	// no input check is performed
	uint8_t hex_byte[3];

	for(int i = 0; i < EDSIGN_PUBLIC_KEY_SIZE; i++) {
		hex_byte[0] = argv[1][2*i];
		hex_byte[1] = argv[1][2*i + 1];
		hex_byte[2] = 0;

		public[i] = strtol(hex_byte, NULL, 16);
	}

	for(int i = 0; i < EDSIGN_SIGNATURE_SIZE; i++) {
		hex_byte[0] = argv[2][2*i];
		hex_byte[1] = argv[2][2*i + 1];
		hex_byte[2] = 0;

		signature[i] = strtol(hex_byte, NULL, 16);
	}

	FILE* message_file = fopen(argv[3], "r");
	fseek(message_file, 0, SEEK_END);
	long size = ftell(message_file);
	rewind(message_file);

	uint8_t* message = malloc(size);

	for(unsigned long i = 0; i < size; i++) {
		message[i] = fgetc(message_file);
	}

	fclose(message_file);
	uint8_t ret;
	struct sha512_state state;
	if(size <= EDSIGN_BLOCK_SIZE - 64) {
		ret = edsign_verify_init(&state, signature, public, message, size);
	} else {
		edsign_verify_init(&state, signature, public, message, EDSIGN_BLOCK_SIZE - 64);

		unsigned long i;
		for(i = EDSIGN_BLOCK_SIZE - 64; i < size - EDSIGN_BLOCK_SIZE; i += EDSIGN_BLOCK_SIZE)
			edsign_verify_block(&state, message+i);

		ret = edsign_verify_final(&state, signature, public, message+i, size);
	}
	if(ret) {
		printf("Valid\n");
		return 0;
	}
	else {
		printf("Invalid\n");
		return 1;
	}
}

